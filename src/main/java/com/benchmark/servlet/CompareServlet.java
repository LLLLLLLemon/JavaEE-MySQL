package com.benchmark.servlet;

import com.benchmark.dao.ModelDAO;
import com.benchmark.entity.ModelCompareVO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

@WebServlet("/compare")
public class CompareServlet extends HttpServlet {

    private ModelDAO modelDAO = new ModelDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String idsParam = req.getParameter("ids");
        if (idsParam == null || idsParam.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/");
            return;
        }

        List<String> ids = Arrays.stream(idsParam.split(","))
                .map(String::trim)
                .filter(s -> !s.isEmpty())
                .collect(Collectors.toList());

        if (ids.size() < 2 || ids.size() > 5) {
            resp.sendRedirect(req.getContextPath() + "/");
            return;
        }

        List<ModelCompareVO> models = modelDAO.findModelsByIds(ids);
        req.setAttribute("models", models);

        // 传递来源页标识，用于返回链接
        String source = req.getParameter("source");
        req.setAttribute("source", source);

        // 计算各指标的最优值（用于表格高亮）
        req.setAttribute("maxCtx", models.stream()
                .map(ModelCompareVO::getContextWindow).filter(java.util.Objects::nonNull)
                .max(Integer::compare).orElse(null));
        req.setAttribute("maxIntel", models.stream()
                .map(ModelCompareVO::getArtifIntelIdx).filter(java.util.Objects::nonNull)
                .max(BigDecimal::compareTo).orElse(null));
        req.setAttribute("maxOmni", models.stream()
                .map(ModelCompareVO::getArtifOmniIdx).filter(java.util.Objects::nonNull)
                .max(BigDecimal::compareTo).orElse(null));
        req.setAttribute("minPrice", models.stream()
                .map(ModelCompareVO::getBlendedPrice).filter(java.util.Objects::nonNull)
                .min(BigDecimal::compareTo).orElse(null));
        req.setAttribute("maxTps", models.stream()
                .map(ModelCompareVO::getMedianTokensS).filter(java.util.Objects::nonNull)
                .max(BigDecimal::compareTo).orElse(null));
        req.setAttribute("minLatency", models.stream()
                .map(ModelCompareVO::getLatencyFirstChunk).filter(java.util.Objects::nonNull)
                .min(BigDecimal::compareTo).orElse(null));
        req.setAttribute("minRespTime", models.stream()
                .map(ModelCompareVO::getTotalResponseTime).filter(java.util.Objects::nonNull)
                .min(BigDecimal::compareTo).orElse(null));

        req.getRequestDispatcher("/WEB-INF/views/compare.jsp").forward(req, resp);
    }
}
