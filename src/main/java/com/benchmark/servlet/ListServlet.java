package com.benchmark.servlet;

import com.benchmark.dao.CreatorDAO;
import com.benchmark.dao.ModelDAO;
import com.benchmark.dao.ModelMetricDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/list")
public class ListServlet extends HttpServlet {

    private CreatorDAO creatorDAO = new CreatorDAO();
    private ModelDAO modelDAO = new ModelDAO();
    private ModelMetricDAO metricDAO = new ModelMetricDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String type = req.getParameter("type");
        String viewPath;

        if ("creators".equals(type)) {
            req.setAttribute("dataList", creatorDAO.findAll());
            viewPath = "/WEB-INF/views/creators.jsp";
        } else if ("models".equals(type)) {
            req.setAttribute("dataList", modelDAO.findAll());
            viewPath = "/WEB-INF/views/models.jsp";
        } else if ("metrics".equals(type)) {
            req.setAttribute("dataList", metricDAO.findAll());
            viewPath = "/WEB-INF/views/metrics.jsp";
        } else {
            resp.sendRedirect(req.getContextPath() + "/");
            return;
        }

        req.getRequestDispatcher(viewPath).forward(req, resp);
    }
}
