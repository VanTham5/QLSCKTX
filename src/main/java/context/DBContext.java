package context;

import java.sql.Connection;
import java.sql.DriverManager;

public class DBContext {
    private final String serverName = "mysql-qlscktx05-qlscktx-05.h.aivencloud.com";
    private final String dbName = "defaultdb";
    private final String portNumber = "25275";
    private final String userID = "avnadmin";

    public Connection getConnection() throws Exception {
        String password = System.getenv("DB_PASSWORD");
        if (password == null || password.isBlank()) {
            throw new IllegalStateException("The DB_PASSWORD environment variable is required.");
        }

        String url = "jdbc:mysql://" + serverName + ":" + portNumber + "/" + dbName
                + "?useUnicode=true&characterEncoding=UTF-8&useSSL=true&requireSSL=true&allowPublicKeyRetrieval=true&serverTimezone=Asia/Ho_Chi_Minh";
        Class.forName("com.mysql.cj.jdbc.Driver");
        return DriverManager.getConnection(url, userID, password);
    }
}
