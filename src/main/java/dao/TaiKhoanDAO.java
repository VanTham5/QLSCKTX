package dao;

import context.DBContext;
import model.TaiKhoan;
import org.mindrot.jbcrypt.BCrypt;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class TaiKhoanDAO {

    // Kiểm tra mật khẩu: hỗ trợ cả mật khẩu đã mã hóa BCrypt và mật khẩu cũ chưa mã hóa trong DB
    private boolean isPasswordMatch(String rawPass, String storedPass) {
        if (rawPass == null || storedPass == null) {
            return false;
        }
        if (storedPass.startsWith("$2a$") || storedPass.startsWith("$2b$") || storedPass.startsWith("$2y$")) {
            return BCrypt.checkpw(rawPass, storedPass);
        }
        return rawPass.equals(storedPass);
    }

    public TaiKhoan checkLogin(String user, String pass) {
        String query = "SELECT * FROM tai_khoan WHERE ten_dang_nhap = ? AND trang_thai = 1";
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setString(1, user);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    String storedPass = rs.getString("mat_khau");
                    if (isPasswordMatch(pass, storedPass)) {
                        TaiKhoan tk = new TaiKhoan(
                                rs.getInt("tai_khoan_id"),
                                rs.getString("ten_dang_nhap"),
                                storedPass,
                                rs.getString("ho_ten"),
                                rs.getString("vai_tro"),
                                rs.getBoolean("trang_thai"),
                                rs.getString("so_dien_thoai")
                        );
                        tk.setEmail(rs.getString("email"));
                        return tk;
                    }
                }
            }
        } catch (Exception e) {
            System.out.println("LỖI ĐĂNG NHẬP AIVEN: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }

    // Kiểm tra tên đăng nhập đã tồn tại chưa
    public boolean checkExistUsername(String username) {
        String query = "SELECT 1 FROM tai_khoan WHERE ten_dang_nhap = ?";
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setString(1, username);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // Đăng ký tài khoản Sinh viên mới (mã hóa mật khẩu bằng BCrypt)
    public boolean registerStudent(String username, String password, String fullName) {
        if (checkExistUsername(username)) {
            return false;
        }

        String hashedPass = BCrypt.hashpw(password, BCrypt.gensalt(10));
        String queryTK = "INSERT INTO tai_khoan (ten_dang_nhap, mat_khau, ho_ten, vai_tro, trang_thai) VALUES (?, ?, ?, 'SINH_VIEN', 1)";

        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(queryTK, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, username);
            ps.setString(2, hashedPass);
            ps.setString(3, fullName);

            int result = ps.executeUpdate();
            if (result > 0) {
                try (ResultSet generatedKeys = ps.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        int newTaiKhoanId = generatedKeys.getInt(1);
                        String querySV = "INSERT INTO sinh_vien (tai_khoan_id, phong_id) VALUES (?, 1)";
                        try (PreparedStatement psSV = conn.prepareStatement(querySV)) {
                            psSV.setInt(1, newTaiKhoanId);
                            psSV.executeUpdate();
                        }
                    }
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

    // Cập nhật thông tin cho NHÂN VIÊN / ADMIN
    public boolean updateProfileEmployee(int taiKhoanId, String hoTen, String sdt, String email) {
        String queryTK = "UPDATE tai_khoan SET ho_ten = ?, so_dien_thoai = ?, email = ? WHERE tai_khoan_id = ?";
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement psTK = conn.prepareStatement(queryTK)) {
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

    public Map<String, String> getEmployeeProfile(int accountId) {
        String sql = "SELECT ho_ten, so_dien_thoai, email FROM tai_khoan WHERE tai_khoan_id = ?";
        try (Connection connection = new DBContext().getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, accountId);
            try (ResultSet result = statement.executeQuery()) {
                if (result.next()) {
                    Map<String, String> profile = new LinkedHashMap<>();
                    profile.put("fullName", result.getString("ho_ten"));
                    profile.put("phone", result.getString("so_dien_thoai"));
                    profile.put("email", result.getString("email"));
                    return profile;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // Đổi mật khẩu (xác thực mật khẩu cũ và mã hóa mật khẩu mới bằng BCrypt)
    public boolean changePassword(int taiKhoanId, String oldPass, String newPass) {
        String selectSql = "SELECT mat_khau FROM tai_khoan WHERE tai_khoan_id = ?";
        String updateSql = "UPDATE tai_khoan SET mat_khau = ? WHERE tai_khoan_id = ?";
        try (Connection connection = new DBContext().getConnection();
             PreparedStatement selectStmt = connection.prepareStatement(selectSql)) {
            selectStmt.setInt(1, taiKhoanId);
            try (ResultSet rs = selectStmt.executeQuery()) {
                if (!rs.next()) {
                    return false;
                }
                String storedPass = rs.getString("mat_khau");
                if (!isPasswordMatch(oldPass, storedPass)) {
                    return false;
                }
            }
            String hashedNewPass = BCrypt.hashpw(newPass, BCrypt.gensalt(10));
            try (PreparedStatement updateStmt = connection.prepareStatement(updateSql)) {
                updateStmt.setString(1, hashedNewPass);
                updateStmt.setInt(2, taiKhoanId);
                return updateStmt.executeUpdate() > 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // Lấy danh sách tài khoản theo vai trò (Loại trừ ADMIN)
    public List<TaiKhoan> getAdminAccounts(String role, String team, String status, String keyword, int limit, int offset) {
        List<TaiKhoan> list = new ArrayList<>();
        List<String> parameters = new ArrayList<>();
        String query = "SELECT tk.tai_khoan_id, tk.ten_dang_nhap, tk.ho_ten, tk.vai_tro, tk.trang_thai, tk.so_dien_thoai, tt.ten_to "
                + adminAccountConditions(role, team, status, keyword, parameters)
                + "ORDER BY tk.tai_khoan_id DESC LIMIT ? OFFSET ?";
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            for (int i = 0; i < parameters.size(); i++) {
                ps.setString(i + 1, parameters.get(i));
            }
            ps.setInt(parameters.size() + 1, limit);
            ps.setInt(parameters.size() + 2, offset);
            try (ResultSet rs = ps.executeQuery()) {
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
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // Cập nhật trạng thái tài khoản (1: Hoạt động, 0: Ngừng hoạt động)
    public int countAdminAccounts(String role, String team, String status, String keyword) {
        List<String> parameters = new ArrayList<>();
        String query = "SELECT COUNT(*) " + adminAccountConditions(role, team, status, keyword, parameters);
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            for (int i = 0; i < parameters.size(); i++) {
                ps.setString(i + 1, parameters.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
            return 0;
        }
    }

    private String adminAccountConditions(String role, String team, String status, String keyword, List<String> parameters) {
        StringBuilder sql = new StringBuilder("FROM tai_khoan tk "
                + "LEFT JOIN nhan_vien nv ON tk.tai_khoan_id = nv.tai_khoan_id "
                + "LEFT JOIN to_nhan_vien tt ON nv.to_id = tt.to_id WHERE tk.vai_tro <> 'ADMIN' ");
        if (!"all".equals(role)) {
            sql.append("AND tk.vai_tro = ? ");
            parameters.add(role);
        }
        if (!team.isEmpty()) {
            sql.append("AND tt.ten_to = ? ");
            parameters.add(team);
        }
        if (!status.isEmpty()) {
            sql.append("AND tk.trang_thai = ? ");
            parameters.add(status);
        }
        if (!keyword.isEmpty()) {
            sql.append("AND LOCATE(?, LOWER(CONCAT_WS(' ', CONCAT('#TK', tk.tai_khoan_id), "
                    + "tk.ho_ten, tk.ten_dang_nhap, tk.so_dien_thoai))) > 0 ");
            parameters.add(keyword.toLowerCase(java.util.Locale.ROOT));
        }
        return sql.toString();
    }

    public boolean updateAccountStatus(int taiKhoanId, int trangThaiMoi) {
        String query = "UPDATE tai_khoan SET trang_thai = ? WHERE tai_khoan_id = ? AND vai_tro <> 'ADMIN'";
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
        Map<String, Object> team = new LinkedHashMap<String, Object>();
        List<Object> members = new ArrayList<>();
        team.put("members", members);
        try (Connection connection = new DBContext().getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, accountId);
            try (ResultSet result = statement.executeQuery()) {
                while (result.next()) {
                    team.put("name", result.getString("ten_to"));
                    String name = result.getString("ho_ten");
                    if (name != null) {
                        Map<String, String> member = new LinkedHashMap<String, String>();
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

    // Admin cấp tài khoản mới (mã hóa mật khẩu bằng BCrypt)
    public boolean createAccountByAdmin(String hoTen, String tenDangNhap, String matKhau, String vaiTro, Integer toId) {
        String hashedPass = BCrypt.hashpw(matKhau, BCrypt.gensalt(10));
        String sqlTaiKhoan = "INSERT INTO tai_khoan (ho_ten, ten_dang_nhap, mat_khau, vai_tro, trang_thai) VALUES (?, ?, ?, ?, 1)";
        try (Connection conn = new DBContext().getConnection()) {
            conn.setAutoCommit(false);

            int newTaiKhoanId = -1;
            try (PreparedStatement ps = conn.prepareStatement(sqlTaiKhoan, Statement.RETURN_GENERATED_KEYS)) {
                ps.setString(1, hoTen);
                ps.setString(2, tenDangNhap);
                ps.setString(3, hashedPass);
                ps.setString(4, vaiTro);
                ps.executeUpdate();

                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        newTaiKhoanId = rs.getInt(1);
                    }
                }
            }

            if (newTaiKhoanId <= 0) {
                conn.rollback();
                return false;
            }

            if ("NHAN_VIEN".equals(vaiTro)) {
                String sqlNV = "INSERT INTO nhan_vien (tai_khoan_id, to_id) VALUES (?, ?)";
                try (PreparedStatement psNV = conn.prepareStatement(sqlNV)) {
                    psNV.setInt(1, newTaiKhoanId);
                    psNV.setInt(2, toId);
                    psNV.executeUpdate();
                }
            } else if ("SINH_VIEN".equals(vaiTro)) {
                String sqlSV = "INSERT INTO sinh_vien (tai_khoan_id) VALUES (?)";
                try (PreparedStatement psSV = conn.prepareStatement(sqlSV)) {
                    psSV.setInt(1, newTaiKhoanId);
                    psSV.executeUpdate();
                }
            }

            conn.commit();
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}