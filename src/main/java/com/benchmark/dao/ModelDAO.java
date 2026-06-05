package com.benchmark.dao;

import com.benchmark.entity.Model;

import java.sql.ResultSet;

public class ModelDAO extends BaseDAO<Model> {
    @Override
    protected String getTableName() {
        return "models";
    }

    @Override
    protected Model mapRow(ResultSet rs) throws Exception {
        Model m = new Model();
        m.setModelId(rs.getString("model_id"));
        m.setModelName(rs.getString("model_name"));
        m.setCreatorId(rs.getString("creator_id"));
        m.setContextWindow(rs.getObject("context_window") != null ? rs.getInt("context_window") : null);
        m.setIsOpenSource(rs.getObject("is_open_source") != null ? rs.getBoolean("is_open_source") : null);
        m.setReleaseDate(rs.getDate("release_date"));
        m.setFieldExpertise(rs.getString("field_expertise"));
        m.setVersionUpgradeNote(rs.getString("version_upgrade_note"));
        return m;
    }
}
