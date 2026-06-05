package com.benchmark.dao;

import com.benchmark.entity.Creator;

import java.sql.ResultSet;

public class CreatorDAO extends BaseDAO<Creator> {
    @Override
    protected String getTableName() {
        return "creators";
    }

    @Override
    protected Creator mapRow(ResultSet rs) throws Exception {
        Creator c = new Creator();
        c.setCreatorId(rs.getString("creator_id"));
        c.setCreatorName(rs.getString("creator_name"));
        c.setDescription(rs.getString("description"));
        return c;
    }
}
