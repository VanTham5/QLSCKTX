package context;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;
import java.sql.Connection;

public class DBContext {
    private static final String SERVER_NAME = "mysql-qlscktx05-qlscktx-05.h.aivencloud.com";
    private static final String DB_NAME = "defaultdb";
    private static final String PORT_NUMBER = "25275";
    private static final String USER_ID = "avnadmin";
    private static final String PASSWORD = "";

    private static final HikariDataSource dataSource;

    static {
        HikariConfig config = new HikariConfig();
        String url = "jdbc:mysql://" + SERVER_NAME + ":" + PORT_NUMBER + "/" + DB_NAME
                + "?useUnicode=true&characterEncoding=UTF-8&useSSL=true&requireSSL=true&allowPublicKeyRetrieval=true&serverTimezone=Asia/Ho_Chi_Minh";

        config.setDriverClassName("com.mysql.cj.jdbc.Driver");
        config.setJdbcUrl(url);
        config.setUsername(USER_ID);
        config.setPassword(PASSWORD);

        // Cấu hình Pool phù hợp với gói miễn phí của Aiven
        config.setMaximumPoolSize(5);
        config.setMinimumIdle(2);
        config.setConnectionTimeout(30000);
        config.setIdleTimeout(300000);
        config.setMaxLifetime(1200000);
        config.setPoolName("QLKTX-HikariPool");

        dataSource = new HikariDataSource(config);
    }

    public Connection getConnection() throws Exception {
        return dataSource.getConnection();
    }

    public static void closePool() {
        if (dataSource != null && !dataSource.isClosed()) {
            dataSource.close();
        }
    }
}