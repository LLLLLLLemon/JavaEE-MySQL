package com.benchmark.util;

import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;

public class DBUtil {
    private static String driver;
    private static String url;
    private static String username;
    private static String password;

    static {
        try (InputStream is = DBUtil.class.getClassLoader()
                .getResourceAsStream("db.properties")) {
            Properties props = new Properties();
            props.load(is);
            driver = props.getProperty("db.driver");
            url = props.getProperty("db.url");
            username = props.getProperty("db.username");
            password = props.getProperty("db.password");
            Class.forName(driver);
        } catch (Exception e) {
            throw new RuntimeException("数据库配置文件加载失败", e);
        }
    }

    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(url, username, password);
    }
}
