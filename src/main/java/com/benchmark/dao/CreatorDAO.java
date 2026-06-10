package com.benchmark.dao;

import com.benchmark.entity.Creator;
import com.benchmark.util.DBUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

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

    /** 新增厂商 */
    public void save(Creator c) throws SQLException {
        String sql = "INSERT INTO creators (creator_id, creator_name, description) VALUES (?, ?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, c.getCreatorId());
            ps.setString(2, c.getCreatorName());
            ps.setString(3, c.getDescription());
            ps.executeUpdate();
        }
    }

    /** 更新厂商（不修改creator_id） */
    public void update(Creator c) throws SQLException {
        String sql = "UPDATE creators SET creator_name = ?, description = ? WHERE creator_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, c.getCreatorName());
            ps.setString(2, c.getDescription());
            ps.setString(3, c.getCreatorId());
            ps.executeUpdate();
        }
    }

    /** 删除厂商 */
    public void deleteById(String creatorId) throws SQLException {
        String sql = "DELETE FROM creators WHERE creator_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, creatorId);
            ps.executeUpdate();
        }
    }

    /** 检查厂商下是否有模型 */
    public boolean hasRelatedModels(String creatorId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM models WHERE creator_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, creatorId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        }
        return false;
    }
}
