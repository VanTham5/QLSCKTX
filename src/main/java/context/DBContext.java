package context;

import java.sql.Connection;
import java.sql.DriverManager;

public class DBContext {
    private final String serverName = "localhost";
    private final String dbName = "qlsucoktx"; // Tên database chuẩn của bạn
    private final String portNumber = "3306";
    private final String userID = "root";
    private final String password = "123456"; // Đổi lại pass MySQL của bạn ở đây nếu cần

    public Connection getConnection() throws Exception {
        String url = "jdbc:mysql://" + serverName + ":" + portNumber + "/" + dbName + "?useUnicode=true&characterEncoding=UTF-8";
        Class.forName("com.mysql.cj.jdbc.Driver");
        return DriverManager.getConnection(url, userID, password);
    }
}