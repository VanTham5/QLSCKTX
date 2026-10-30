package context;
import java.sql.Connection;
import java.sql.DriverManager;

public class DBContext {
    private final String serverName = "localhost";
    private final String dbName = "QLSuCoKTX";
    private final String portNumber = "3306";
    private final String userID = "root";
    private final String password = "123456"; // Đổi mật khẩu tại đây

    public Connection getConnection() throws Exception {
        String url = "jdbc:mysql://" + serverName + ":" + portNumber + "/" + dbName + "?useUnicode=true&characterEncoding=UTF-8";
        Class.forName("com.mysql.cj.jdbc.Driver");
        return DriverManager.getConnection(url, userID, password);
    }

    // Test thử kết nối
    public static void main(String[] args) {
        try {
            DBContext db = new DBContext();
            Connection conn = db.getConnection();
            if (conn != null) {
                System.out.println("Kết nối MySQL thành công!");
                conn.close();
            }
        } catch (Exception e) {
            System.out.println("Lỗi kết nối: " + e.getMessage());
        }
    }
}