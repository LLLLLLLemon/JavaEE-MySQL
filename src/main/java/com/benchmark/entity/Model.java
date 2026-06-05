package com.benchmark.entity;

import java.sql.Date;

public class Model {
    private String modelId;
    private String modelName;
    private String creatorId;
    private Integer contextWindow;
    private Boolean isOpenSource;
    private Date releaseDate;
    private String fieldExpertise;
    private String versionUpgradeNote;

    public String getModelId() { return modelId; }
    public void setModelId(String modelId) { this.modelId = modelId; }
    public String getModelName() { return modelName; }
    public void setModelName(String modelName) { this.modelName = modelName; }
    public String getCreatorId() { return creatorId; }
    public void setCreatorId(String creatorId) { this.creatorId = creatorId; }
    public Integer getContextWindow() { return contextWindow; }
    public void setContextWindow(Integer contextWindow) { this.contextWindow = contextWindow; }
    public Boolean getIsOpenSource() { return isOpenSource; }
    public void setIsOpenSource(Boolean isOpenSource) { this.isOpenSource = isOpenSource; }
    public Date getReleaseDate() { return releaseDate; }
    public void setReleaseDate(Date releaseDate) { this.releaseDate = releaseDate; }
    public String getFieldExpertise() { return fieldExpertise; }
    public void setFieldExpertise(String fieldExpertise) { this.fieldExpertise = fieldExpertise; }
    public String getVersionUpgradeNote() { return versionUpgradeNote; }
    public void setVersionUpgradeNote(String versionUpgradeNote) { this.versionUpgradeNote = versionUpgradeNote; }
}
