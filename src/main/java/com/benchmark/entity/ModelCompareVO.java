package com.benchmark.entity;

import java.math.BigDecimal;
import java.sql.Date;

/**
 * 模型对比视图对象 - 包含模型基本信息 + 厂商名称 + 性能指标
 */
public class ModelCompareVO {
    private String modelId;
    private String modelName;
    private String creatorId;
    private String creatorName;
    private Integer contextWindow;
    private Boolean isOpenSource;
    private Date releaseDate;
    private String fieldExpertise;

    // 性能指标
    private BigDecimal artifIntelIdx;
    private BigDecimal artifOmniIdx;
    private BigDecimal terminalBenchHard;
    private BigDecimal aaOmniAccuracy;
    private BigDecimal blendedPrice;
    private BigDecimal medianTokensS;
    private BigDecimal latencyFirstChunk;
    private BigDecimal totalResponseTime;

    public String getModelId() { return modelId; }
    public void setModelId(String modelId) { this.modelId = modelId; }
    public String getModelName() { return modelName; }
    public void setModelName(String modelName) { this.modelName = modelName; }
    public String getCreatorId() { return creatorId; }
    public void setCreatorId(String creatorId) { this.creatorId = creatorId; }
    public String getCreatorName() { return creatorName; }
    public void setCreatorName(String creatorName) { this.creatorName = creatorName; }
    public Integer getContextWindow() { return contextWindow; }
    public void setContextWindow(Integer contextWindow) { this.contextWindow = contextWindow; }
    public Boolean getIsOpenSource() { return isOpenSource; }
    public void setIsOpenSource(Boolean isOpenSource) { this.isOpenSource = isOpenSource; }
    public Date getReleaseDate() { return releaseDate; }
    public void setReleaseDate(Date releaseDate) { this.releaseDate = releaseDate; }
    public String getFieldExpertise() { return fieldExpertise; }
    public void setFieldExpertise(String fieldExpertise) { this.fieldExpertise = fieldExpertise; }
    public BigDecimal getArtifIntelIdx() { return artifIntelIdx; }
    public void setArtifIntelIdx(BigDecimal artifIntelIdx) { this.artifIntelIdx = artifIntelIdx; }
    public BigDecimal getArtifOmniIdx() { return artifOmniIdx; }
    public void setArtifOmniIdx(BigDecimal artifOmniIdx) { this.artifOmniIdx = artifOmniIdx; }
    public BigDecimal getTerminalBenchHard() { return terminalBenchHard; }
    public void setTerminalBenchHard(BigDecimal terminalBenchHard) { this.terminalBenchHard = terminalBenchHard; }
    public BigDecimal getAaOmniAccuracy() { return aaOmniAccuracy; }
    public void setAaOmniAccuracy(BigDecimal aaOmniAccuracy) { this.aaOmniAccuracy = aaOmniAccuracy; }
    public BigDecimal getBlendedPrice() { return blendedPrice; }
    public void setBlendedPrice(BigDecimal blendedPrice) { this.blendedPrice = blendedPrice; }
    public BigDecimal getMedianTokensS() { return medianTokensS; }
    public void setMedianTokensS(BigDecimal medianTokensS) { this.medianTokensS = medianTokensS; }
    public BigDecimal getLatencyFirstChunk() { return latencyFirstChunk; }
    public void setLatencyFirstChunk(BigDecimal latencyFirstChunk) { this.latencyFirstChunk = latencyFirstChunk; }
    public BigDecimal getTotalResponseTime() { return totalResponseTime; }
    public void setTotalResponseTime(BigDecimal totalResponseTime) { this.totalResponseTime = totalResponseTime; }
}
