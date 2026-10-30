package dao;

import context.DBContext;
import model.TaiKhoan;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class TaiKhoanDAO {
    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    public TaiKhoan checkLogin(String user, String pass) {
        // Kiểm tra user, pass và đảm bảo tài khoản đang hoạt động (trang_thai = 1)
        String query = "SELECT * FROM TAI_KHOAN WHERE ten_dang_nhap = ? AND mat_khau = ? AND trang_thai = 1";
        try {
            conn = new DBContext().getConnection(); // Mở kết nối tới MySQL
            ps = conn.prepareStatement(query);
            ps.setString(1, user);
            ps.setString(2, pass);
            rs = ps.executeQuery();

            if (rs.next()) {
                return new TaiKhoan(
                        rs.getInt("tai_khoan_id"),
                        rs.getString("ten_dang_nhap"),
                        rs.getString("mat_khau"),
                        rs.getString("ho_ten"),
                        rs.getString("vai_tro"),
                        rs.getBoolean("trang_thai")
                );
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null; // Trả về null nếu sai tài khoản/mật khẩu
    }
}