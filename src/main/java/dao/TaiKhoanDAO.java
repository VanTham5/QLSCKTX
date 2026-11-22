package dao;

import context.DBContext;
import model.TaiKhoan;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class TaiKhoanDAO {
    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    public TaiKhoan checkLogin(String user, String pass) {
        // Kiểm tra user, pass và đảm bảo tài khoản đang hoạt động (trang_thai = 1)
        String query = "SELECT * FROM tai_khoan WHERE ten_dang_nhap = ? AND mat_khau = ? AND trang_thai = 1";
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
                        rs.getBoolean("trang_thai"),
                        rs.getString("so_dien_thoai")
                );
            }
        }  catch (Exception e) {
        System.out.println("LỖI ĐĂNG NHẬP AIVEN: " + e.getMessage());
        e.printStackTrace();
    }
        return null; // Trả về null nếu sai tài khoản/mật khẩu
    }

    // Hàm kiểm tra xem tên đăng nhập (Mã SV) đã tồn tại trong Database chưa
    public boolean checkExistUsername(String username) {
        String query = "SELECT * FROM tai_khoan WHERE ten_dang_nhap = ?";
        try {
            conn = new DBContext().getConnection();
            ps = conn.prepareStatement(query);
            ps.setString(1, username);
            rs = ps.executeQuery();

            // Nếu có kết quả trả về nghĩa là tài khoản đã tồn tại
            if (rs.next()) {
                return true;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // Hàm Đăng ký tài khoản Sinh viên mới
    public boolean registerStudent(String username, String password, String fullName) {
        if (checkExistUsername(username)) {
            return false;
        }

        // ĐÃ SỬA: Thêm cột trang_thai = 1 và sửa vai trò thành 'SINH_VIEN' chuẩn với database
        String queryTK = "INSERT INTO tai_khoan (ten_dang_nhap, mat_khau, ho_ten, vai_tro, trang_thai) VALUES (?, ?, ?, 'SINH_VIEN', 1)";

        try {
            conn = new DBContext().getConnection();

            // Bật tính năng lấy lại ID (tai_khoan_id) vừa được tự động tăng (Auto Increment)
            ps = conn.prepareStatement(queryTK, Statement.RETURN_GENERATED_KEYS);
            ps.setString(1, username);
            ps.setString(2, password);
            ps.setString(3, fullName);

            int result = ps.executeUpdate();

            if (result > 0) {
                ResultSet generatedKeys = ps.getGeneratedKeys();
                if (generatedKeys.next()) {
                    int newTaiKhoanId = generatedKeys.getInt(1);

                    // Thêm thông tin vào bảng sinh_vien để liên kết tài khoản
                    String querySV = "INSERT INTO sinh_vien (tai_khoan_id, phong_id) VALUES (?, 1)";
                    PreparedStatement psSV = conn.prepareStatement(querySV);
                    psSV.setInt(1, newTaiKhoanId);
                    psSV.executeUpdate();
                }
                return true;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public Map<String, Object> getStudentProfile(int accountId) {
        String query = "SELECT tk.ho_ten, tk.so_dien_thoai, tk.email, sv.phong_id, sv.ma_sinh_vien, sv.khoa, sv.lop " +
                "FROM tai_khoan tk LEFT JOIN sinh_vien sv ON sv.tai_khoan_id = tk.tai_khoan_id " +
                "WHERE tk.tai_khoan_id = ? AND tk.vai_tro = 'SINH_VIEN'";
        try (Connection connection = new DBContext().getConnection();
             PreparedStatement statement = connection.prepareStatement(query)) {
            statement.setInt(1, accountId);
            try (ResultSet result = statement.executeQuery()) {
                if (result.next()) {
                    Map<String, Object> profile = new LinkedHashMap<>();
                    profile.put("fullName", result.getString("ho_ten"));
                    profile.put("sdt", result.getString("so_dien_thoai"));
                    profile.put("email", result.getString("email"));
                    profile.put("phongId", result.getObject("phong_id"));
                    profile.put("maSV", result.getString("ma_sinh_vien"));
                    profile.put("khoa", result.getString("khoa"));
                    profile.put("lop", result.getString("lop"));
                    return profile;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public Map<Integer, String> getProfileRooms() {
        Map<Integer, String> rooms = new LinkedHashMap<>();
        String query = "SELECT phong_id, ma_phong, toa_nha FROM phong ORDER BY toa_nha, ma_phong";
        try (Connection connection = new DBContext().getConnection();
             PreparedStatement statement = connection.prepareStatement(query);
             ResultSet result = statement.executeQuery()) {
            while (result.next()) {
                rooms.put(result.getInt("phong_id"), result.getString("ma_phong") + " - " + result.getString("toa_nha"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return rooms;
    }

    public boolean updateProfileStudent(int taiKhoanId, String hoTen, String sdt, String email, int phongId, String maSV, String khoa, String lop) {
        String query = "UPDATE tai_khoan tk JOIN sinh_vien sv ON sv.tai_khoan_id = tk.tai_khoan_id " +
                "JOIN phong p ON p.phong_id = ? " +
                "SET tk.ho_ten = ?, tk.so_dien_thoai = ?, tk.email = ?, " +
                "sv.phong_id = p.phong_id, sv.ma_sinh_vien = ?, sv.khoa = ?, sv.lop = ? " +
                "WHERE tk.tai_khoan_id = ? AND tk.vai_tro = 'SINH_VIEN'";
        try (Connection connection = new DBContext().getConnection();
             PreparedStatement statement = connection.prepareStatement(query)) {
            statement.setInt(1, phongId);
            statement.setString(2, hoTen);
            statement.setString(3, sdt);
            statement.setString(4, email);
            statement.setString(5, maSV);
            statement.setString(6, khoa);
            statement.setString(7, lop);
            statement.setInt(8, taiKhoanId);
            return statement.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // 2. Cập nhật thông tin cho NHÂN VIÊN / ADMIN
    public boolean updateProfileEmployee(int taiKhoanId, String hoTen, String sdt, String email) {
        String queryTK = "UPDATE tai_khoan SET ho_ten = ?, so_dien_thoai = ?, email = ? WHERE tai_khoan_id = ?";
        try {
            Connection conn = new DBContext().getConnection();
            PreparedStatement psTK = conn.prepareStatement(queryTK);
            psTK.setString(1, hoTen);
            psTK.setString(2, sdt);
            psTK.setString(3, email);
            psTK.setInt(4, taiKhoanId);
            return psTK.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // Hàm Đổi mật khẩu
    public boolean changePassword(int taiKhoanId, String oldPass, String newPass) {
        // 1. Kiểm tra xem mật khẩu cũ có đúng không
        String checkQuery = "SELECT * FROM tai_khoan WHERE tai_khoan_id = ? AND mat_khau = ?";
        String updateQuery = "UPDATE tai_khoan SET mat_khau = ? WHERE tai_khoan_id = ?";
        try {
            Connection conn = new DBContext().getConnection();
            PreparedStatement psCheck = conn.prepareStatement(checkQuery);
            psCheck.setInt(1, taiKhoanId);
            psCheck.setString(2, oldPass);
            ResultSet rs = psCheck.executeQuery();

            // Nếu tìm thấy tài khoản khớp với mật khẩu cũ
            if (rs.next()) {
                PreparedStatement psUpdate = conn.prepareStatement(updateQuery);
                psUpdate.setString(1, newPass);
                psUpdate.setInt(2, taiKhoanId);
                int result = psUpdate.executeUpdate();
                return result > 0; // Đổi thành công
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false; // Mật khẩu cũ sai hoặc lỗi kết nối
    }

    // Lấy danh sách tài khoản theo vai trò (Loại trừ ADMIN) một cách an toàn
    public List<TaiKhoan> getAccountsByRole(String role) {
        List<TaiKhoan> list = new ArrayList<>();

        // Đã sửa 'to_ky_thuat' thành 'to_nhan_vien' khớp với cơ sở dữ liệu của bạn
        String query = "SELECT tk.tai_khoan_id, tk.ten_dang_nhap, tk.ho_ten, tk.vai_tro, tk.trang_thai, tk.so_dien_thoai, tt.ten_to " +
                "FROM tai_khoan tk " +
                "LEFT JOIN nhan_vien nv ON tk.tai_khoan_id = nv.tai_khoan_id " +
                "LEFT JOIN to_nhan_vien tt ON nv.to_id = tt.to_id " +
                "WHERE tk.vai_tro != 'ADMIN' ";

        if (role != null && !role.isEmpty() && !role.equals("all")) {
            query += "AND tk.vai_tro = ? ";
        }
        query += "ORDER BY tk.tai_khoan_id DESC";

        try {
            Connection conn = new DBContext().getConnection();
            PreparedStatement ps = conn.prepareStatement(query);
            if (role != null && !role.isEmpty() && !role.equals("all")) {
                ps.setString(1, role);
            }
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                TaiKhoan tk = new TaiKhoan();
                tk.setTaiKhoanId(rs.getInt("tai_khoan_id"));
                tk.setTenDangNhap(rs.getString("ten_dang_nhap"));
                tk.setHoTen(rs.getString("ho_ten"));
                tk.setVaiTro(rs.getString("vai_tro"));
                tk.setTrangThai(rs.getBoolean("trang_thai"));
                tk.setSoDienThoai(rs.getString("so_dien_thoai") != null ? rs.getString("so_dien_thoai") : "Chưa cập nhật");

                String tenTo = rs.getString("ten_to");
                if ("NHAN_VIEN".equals(tk.getVaiTro())) {
                    tk.setTenTo(tenTo != null ? tenTo : "Chưa phân tổ");
                } else {
                    tk.setTenTo("---");
                }

                list.add(tk);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // Hàm phụ lấy tên tổ của nhân viên (tránh lỗi JOIN toàn cục)
    private String getTenToByTaiKhoanId(int taiKhoanId, Connection conn) {
        String tenTo = "Chưa phân tổ";
        String query = "SELECT tt.ten_to FROM nhan_vien nv " +
                "JOIN to_ky_thuat tt ON nv.to_id = tt.to_id " +
                "WHERE nv.tai_khoan_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setInt(1, taiKhoanId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    String t = rs.getString("ten_to");
                    if (t != null) tenTo = t;
                }
            }
        } catch (Exception e) {
            // Nếu bảng nhan_vien hoặc to_ky_thuat có tên khác, code vẫn chạy bình thường và trả về "Chưa phân tổ"
        }
        return tenTo;
    }

    // Cập nhật trạng thái tài khoản (1: Hoạt động, 0: Ngừng hoạt động)
    public boolean updateAccountStatus(int taiKhoanId, int trangThaiMoi) {
        String query = "UPDATE tai_khoan SET trang_thai = ? WHERE tai_khoan_id = ?";
        try (Connection connection = new DBContext().getConnection();
             PreparedStatement statement = connection.prepareStatement(query)) {
            statement.setInt(1, trangThaiMoi);
            statement.setInt(2, taiKhoanId);
            return statement.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public Map<String, Object> getStaffTeam(int accountId) throws java.sql.SQLException {
        String sql = "SELECT t.ten_to, tk.ho_ten, tk.so_dien_thoai "
                + "FROM nhan_vien nv JOIN to_nhan_vien t ON t.to_id = nv.to_id "
                + "LEFT JOIN nhan_vien colleague ON colleague.to_id = nv.to_id "
                + "AND colleague.tai_khoan_id <> nv.tai_khoan_id "
                + "LEFT JOIN tai_khoan tk ON tk.tai_khoan_id = colleague.tai_khoan_id AND tk.trang_thai = 1 "
                + "WHERE nv.tai_khoan_id = ? ORDER BY tk.ho_ten";
        Map<String, Object> team = new LinkedHashMap<>();
        List<Map<String, String>> members = new ArrayList<>();
        team.put("members", members);
        try (Connection connection = new DBContext().getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, accountId);
            try (ResultSet result = statement.executeQuery()) {
                while (result.next()) {
                    team.put("name", result.getString("ten_to"));
                    String name = result.getString("ho_ten");
                    if (name != null) {
                        Map<String, String> member = new LinkedHashMap<>();
                        member.put("name", name);
                        member.put("phone", result.getString("so_dien_thoai"));
                        members.add(member);
                    }
                }
            }
        } catch (java.sql.SQLException e) {
            throw e;
        } catch (Exception e) {
            throw new java.sql.SQLException("Không thể kết nối cơ sở dữ liệu", e);
        }
        return team;
    }
}