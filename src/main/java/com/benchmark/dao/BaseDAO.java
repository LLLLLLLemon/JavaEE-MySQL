package com.benchmark.dao;

import com.benchmark.util.DBUtil;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public abstract class BaseDAO<T> {

    public List<T> findAll() {
        List<T> list = new ArrayList<>();
        String sql = "SELECT * FROM " + getTableName();
        System.out.println("[DEBUG] 执行查询: " + sql);
        try (Connection conn = DBUtil.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                list.add(mapRow(rs));
            }
            System.out.println("[DEBUG] " + getTableName() + " 查询到 " + list.size() + " 条数据");
        } catch (Exception e) {
            System.err.println("[ERROR] " + getTableName() + " 查询失败: " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    protected abstract String getTableName();
    protected abstract T mapRow(ResultSet rs) throws Exception;
}
