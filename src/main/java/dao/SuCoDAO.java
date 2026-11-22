package dao;

import context.DBContext;
import model.SuCo;
import model.LoaiSuCo;
import model.TaiKhoan;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.LinkedHashMap;
import java.sql.Timestamp;

@SuppressWarnings({"SqlNoDataSourceInspection", "SqlResolve", "SpellCheckingInspection", "CallToPrintStackTrace"})
public class SuCoDAO implements ISuCoDAO {
    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    // 1. Phiên bản KHÔNG THAM SỐ (Để thỏa mãn ISuCoDAO và các nơi gọi cũ)
    @Override
    public List<SuCo> getAllSuCoForStaff() {
        List<SuCo> list = new ArrayList<>();
        String query = "SELECT sc.su_co_id, sc.tieu_de, sc.mo_ta, sc.ghi_chu_xu_ly, sc.muc_do, sc.trang_thai, sc.ngay_gui, " +
                "p.ma_phong, p.toa_nha, " +
                "tk.ho_ten, tk.so_dien_thoai " +
                "FROM su_co sc " +
                "LEFT JOIN phong p ON sc.phong_id = p.phong_id " +
                "LEFT JOIN sinh_vien sv ON sc.sinh_vien_id = sv.sinh_vien_id " +
                "LEFT JOIN tai_khoan tk ON sv.tai_khoan_id = tk.tai_khoan_id " +
                "WHERE sc.trang_thai IN ('Chờ xử lý', 'Đang xử lý') " +
                "ORDER BY FIELD(sc.trang_thai, 'Chờ xử lý', 'Đang xử lý'), sc.ngay_gui DESC";
        try {
            conn = new DBContext().getConnection();
            ps = conn.prepareStatement(query);
            rs = ps.executeQuery();
            while (rs.next()) {
                SuCo sc = new SuCo();
                sc.setSuCoId(rs.getInt("su_co_id"));
                sc.setTieuDe(rs.getString("tieu_de"));
                sc.setMoTa(rs.getString("mo_ta"));
                sc.setGhiChuKyThuat(rs.getString("ghi_chu_xu_ly"));
                sc.setMucDo(rs.getString("muc_do"));
                sc.setTrangThai(rs.getString("trang_thai"));
                sc.setNgayGui(rs.getTimestamp("ngay_gui"));

                String phong = rs.getString("ma_phong") != null ? rs.getString("ma_phong") : "N/A";
                String toa = rs.getString("toa_nha") != null ? rs.getString("toa_nha") : "N/A";
                sc.setViTriPhong("Ph\u00f2ng " + phong + " - T\u00f2a " + toa);

                sc.setTenNguoiGui(rs.getString("ho_ten"));
                sc.setSoDienThoai(rs.getString("so_dien_thoai") != null ? rs.getString("so_dien_thoai") : "Không có");

                list.add(sc);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // 2. Phiên bản CÓ THAM SỐ (Dùng cho EmployeeHomeServlet lọc theo tổ)
    @Override
    public List<SuCo> getAllSuCoForStaff(int taiKhoanId) {
        List<SuCo> list = new ArrayList<>();
        String query = "SELECT sc.su_co_id, sc.tieu_de, sc.mo_ta, sc.ghi_chu_xu_ly, sc.muc_do, sc.trang_thai, sc.ngay_gui, " +
                "p.ma_phong, p.toa_nha, " +
                "tk.ho_ten, tk.so_dien_thoai " +
                "FROM su_co sc " +
                "JOIN loai_su_co lsc ON sc.loai_su_co_id = lsc.loai_su_co_id " +
                "JOIN nhan_vien nv ON lsc.to_id = nv.to_id " +
                "LEFT JOIN phong p ON sc.phong_id = p.phong_id " +
                "LEFT JOIN sinh_vien sv ON sc.sinh_vien_id = sv.sinh_vien_id " +
                "LEFT JOIN tai_khoan tk ON sv.tai_khoan_id = tk.tai_khoan_id " +
                "WHERE nv.tai_khoan_id = ? AND (sc.nhan_vien_id = nv.nhan_vien_id OR (sc.nhan_vien_id IS NULL AND sc.trang_thai <> 'Chờ xử lý')) AND sc.trang_thai IN ('Chờ xử lý', 'Đang xử lý') " +
                "ORDER BY FIELD(sc.trang_thai, 'Chờ xử lý', 'Đang xử lý'), sc.ngay_gui DESC";
        try {
            conn = new DBContext().getConnection();
            ps = conn.prepareStatement(query);
            ps.setInt(1, taiKhoanId);
            rs = ps.executeQuery();
            while (rs.next()) {
                SuCo sc = new SuCo();
                sc.setSuCoId(rs.getInt("su_co_id"));
                sc.setTieuDe(rs.getString("tieu_de"));
                sc.setMoTa(rs.getString("mo_ta"));
                sc.setGhiChuKyThuat(rs.getString("ghi_chu_xu_ly"));
                sc.setMucDo(rs.getString("muc_do"));
                sc.setTrangThai(rs.getString("trang_thai"));
                sc.setNgayGui(rs.getTimestamp("ngay_gui"));

                String phong = rs.getString("ma_phong") != null ? rs.getString("ma_phong") : "N/A";
                String toa = rs.getString("toa_nha") != null ? rs.getString("toa_nha") : "N/A";
                sc.setViTriPhong("Ph\u00f2ng " + phong + " - T\u00f2a " + toa);

                sc.setTenNguoiGui(rs.getString("ho_ten"));
                sc.setSoDienThoai(rs.getString("so_dien_thoai") != null ? rs.getString("so_dien_thoai") : "Không có");

                list.add(sc);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // 2. Nhân viên tiếp nhận hoặc báo cáo hoàn thành sự cố
    public boolean assignStaffToIssue(int issueId, int staffAccountId) throws Exception {
        String sql = "UPDATE su_co sc JOIN loai_su_co lsc ON sc.loai_su_co_id = lsc.loai_su_co_id "
                + "JOIN nhan_vien nv ON nv.to_id = lsc.to_id "
                + "JOIN tai_khoan tk ON tk.tai_khoan_id = nv.tai_khoan_id "
                + "SET sc.nhan_vien_id = nv.nhan_vien_id "
                + "WHERE sc.su_co_id = ? AND tk.tai_khoan_id = ? "
                + "AND tk.trang_thai = 1 AND tk.vai_tro = 'NHAN_VIEN' "
                + "AND sc.trang_thai = 'Chờ xử lý'";
        try (Connection connection = new DBContext().getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, issueId);
            statement.setInt(2, staffAccountId);
            return statement.executeUpdate() == 1;
        }
    }


    public boolean updateStaffIssue(int accountId, int issueId, boolean completed, String note)
            throws java.sql.SQLException {
        String sql = "UPDATE su_co sc JOIN loai_su_co lsc ON sc.loai_su_co_id = lsc.loai_su_co_id "
                + "JOIN nhan_vien nv ON nv.to_id = lsc.to_id "
                + "SET sc.trang_thai = ?, sc.ngay_cap_nhat = CURRENT_TIMESTAMP, sc.nhan_vien_id = nv.nhan_vien_id "
                + (completed ? ", sc.ghi_chu_xu_ly = ? " : "")
                + "WHERE nv.tai_khoan_id = ? AND (sc.nhan_vien_id = nv.nhan_vien_id OR (sc.nhan_vien_id IS NULL AND sc.trang_thai <> 'Chờ xử lý')) AND sc.su_co_id = ? AND sc.trang_thai = ?";
        try (Connection connection = new DBContext().getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            int index = 1;
            statement.setString(index++, completed ? "Đã hoàn thành" : "Đang xử lý");
            if (completed) {
                statement.setString(index++, note);
            }
            statement.setInt(index++, accountId);
            statement.setInt(index++, issueId);
            statement.setString(index, completed ? "Đang xử lý" : "Chờ xử lý");
            return statement.executeUpdate() == 1;
        } catch (java.sql.SQLException e) {
            throw e;
        } catch (Exception e) {
            throw new java.sql.SQLException("Không thể kết nối cơ sở dữ liệu", e);
        }
    }


    public void updateTrangThaiSuCo(int suCoId, String trangThaiMoi) {
        String query = "UPDATE su_co SET trang_thai = ? WHERE su_co_id = ?";
        try {
            conn = new DBContext().getConnection();
            ps = conn.prepareStatement(query);
            ps.setString(1, trangThaiMoi);
            ps.setInt(2, suCoId);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // --- CÁC HÀM DÀNH CHO LUỒNG SINH VIÊN ---

    // 3. Đếm số lượng sự cố theo trạng thái (hoặc đếm tất cả nếu status = null)
    public int countIssueByStatus(int tkId, String status) {
        int count = 0;
        String query = "SELECT COUNT(*) FROM su_co sc " +
                "JOIN sinh_vien sv ON sc.sinh_vien_id = sv.sinh_vien_id " +
                "WHERE sv.tai_khoan_id = ?";
        if (status != null) {
            query += " AND sc.trang_thai = ?";
        }
        try {
            conn = new DBContext().getConnection();
            ps = conn.prepareStatement(query);
            ps.setInt(1, tkId);
            if (status != null) {
                ps.setString(2, status);
            }
            rs = ps.executeQuery();
            if (rs.next()) {
                count = rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return count;
    }

    // 4. Lấy danh sách 5 sự cố mới nhất của sinh viên đó (Đã bổ sung lấy mo_ta)
    public List<SuCo> getTop5RecentIssues(int tkId) {
        List<SuCo> list = new ArrayList<>();
        String query = "SELECT sc.su_co_id, sc.tieu_de, sc.mo_ta, sc.ghi_chu_xu_ly, sc.muc_do, sc.trang_thai, sc.ngay_gui, " +
                "p.ma_phong, p.toa_nha " +
                "FROM su_co sc " +
                "JOIN sinh_vien sv ON sc.sinh_vien_id = sv.sinh_vien_id " +
                "LEFT JOIN phong p ON sc.phong_id = p.phong_id " +
                "WHERE sv.tai_khoan_id = ? " +
                "ORDER BY sc.ngay_gui DESC LIMIT 5";
        try {
            conn = new DBContext().getConnection();
            ps = conn.prepareStatement(query);
            ps.setInt(1, tkId);
            rs = ps.executeQuery();
            while (rs.next()) {
                SuCo sc = new SuCo();
                sc.setSuCoId(rs.getInt("su_co_id"));
                sc.setTieuDe(rs.getString("tieu_de"));
                sc.setMoTa(rs.getString("mo_ta"));
                sc.setGhiChuKyThuat(rs.getString("ghi_chu_xu_ly"));
                sc.setMucDo(rs.getString("muc_do"));
                sc.setTrangThai(rs.getString("trang_thai"));
                sc.setNgayGui(rs.getTimestamp("ngay_gui"));

                String phong = rs.getString("ma_phong") != null ? rs.getString("ma_phong") : "N/A";
                String toa = rs.getString("toa_nha") != null ? rs.getString("toa_nha") : "N/A";
                sc.setViTriPhong("Ph\u00f2ng " + phong + " - T\u00f2a " + toa);

                list.add(sc);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public int countTotalStudents() {
        int count = 0;
        try {
            conn = new context.DBContext().getConnection();
            ps = conn.prepareStatement("SELECT COUNT(*) FROM sinh_vien");
            rs = ps.executeQuery();
            if (rs.next()) count = rs.getInt(1);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return count;
    }

    // Lấy danh sách loại sự cố cho sinh viên chọn khi báo cáo
    public List<LoaiSuCo> getAllLoaiSuCo() {
        List<LoaiSuCo> list = new ArrayList<>();
        String query = "SELECT * FROM loai_su_co";
        try {
            conn = new DBContext().getConnection();
            ps = conn.prepareStatement(query);
            rs = ps.executeQuery();
            while (rs.next()) {
                LoaiSuCo lsc = new LoaiSuCo();
                lsc.setLoaiSuCoId(rs.getInt("loai_su_co_id"));
                lsc.setTenLoai(rs.getString("ten_loai"));
                list.add(lsc);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public boolean insertSuCo(SuCo sc) {
        String query = "INSERT INTO su_co (sinh_vien_id, phong_id, loai_su_co_id, tieu_de, mo_ta, muc_do, trang_thai, ngay_gui) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP)";
        try {
            conn = new context.DBContext().getConnection();
            ps = conn.prepareStatement(query);
            ps.setInt(1, sc.getSinhVienId());
            ps.setInt(2, sc.getPhongId());
            ps.setInt(3, sc.getLoaiSuCoId());
            ps.setString(4, sc.getTieuDe());
            ps.setString(5, sc.getMoTa());
            ps.setString(6, sc.getMucDo());
            ps.setString(7, "Chờ xử lý");

            int result = ps.executeUpdate();
            return result > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // --- HÀM DELETE (Admin xóa sự cố sai/ảo) ---
    @Override
    public boolean deleteSuCo(int suCoId) {
        String query = "DELETE FROM su_co WHERE su_co_id = ?";
        try {
            conn = new context.DBContext().getConnection();
            ps = conn.prepareStatement(query);
            ps.setInt(1, suCoId);

            int result = ps.executeUpdate();
            return result > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // Lấy toàn bộ lịch sử báo cáo của Sinh viên (Có kèm bộ lọc trạng thái)
    public List<SuCo> getHistoryIssues(int tkId, String filter) {
        List<SuCo> list = new ArrayList<>();

        // Chỉ bổ sung lấy thêm lsc.ten_loai từ bảng loai_su_co, giữ nguyên câu lệnh gốc
        String query = "SELECT sc.su_co_id, sc.tieu_de, sc.mo_ta, sc.ghi_chu_xu_ly, sc.muc_do, sc.trang_thai, sc.ngay_gui, lsc.ten_loai " +
                "FROM su_co sc " +
                "JOIN sinh_vien sv ON sc.sinh_vien_id = sv.sinh_vien_id " +
                "LEFT JOIN loai_su_co lsc ON sc.loai_su_co_id = lsc.loai_su_co_id " +
                "WHERE sv.tai_khoan_id = ? ";

        // Kiểm tra bộ lọc và nối thêm điều kiện vào SQL (Giữ nguyên 100%)
        if ("pending".equals(filter)) {
            query += "AND sc.trang_thai = 'Chờ xử lý' ";
        } else if ("processing".equals(filter)) {
            query += "AND sc.trang_thai = 'Đang xử lý' ";
        } else if ("done".equals(filter)) {
            query += "AND sc.trang_thai = 'Đã hoàn thành' ";
        }

        // Sắp xếp mới nhất lên đầu
        query += "ORDER BY sc.ngay_gui DESC";

        try {
            java.sql.Connection conn = new context.DBContext().getConnection();
            java.sql.PreparedStatement ps = conn.prepareStatement(query);
            ps.setInt(1, tkId);
            java.sql.ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                SuCo sc = new SuCo();
                sc.setSuCoId(rs.getInt("su_co_id"));
                sc.setTieuDe(rs.getString("tieu_de"));
                sc.setMoTa(rs.getString("mo_ta"));
                sc.setGhiChuKyThuat(rs.getString("ghi_chu_xu_ly"));
                sc.setMucDo(rs.getString("muc_do"));
                sc.setTrangThai(rs.getString("trang_thai"));
                sc.setNgayGui(rs.getTimestamp("ngay_gui"));
                sc.setTenLoaiSuCo(rs.getString("ten_loai")); // <--- Chỉ thêm đúng dòng này
                list.add(sc);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
    public Map<String, Integer> getThongKeTheoLoai() {
        Map<String, Integer> map = new LinkedHashMap<>();
        String query = "SELECT lsc.ten_loai, COUNT(sc.su_co_id) as so_luong " +
                "FROM su_co sc " +
                "JOIN loai_su_co lsc ON sc.loai_su_co_id = lsc.loai_su_co_id " +
                "GROUP BY lsc.ten_loai";
        try {
            Connection conn = new DBContext().getConnection();
            PreparedStatement ps = conn.prepareStatement(query);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                map.put(rs.getString("ten_loai"), rs.getInt("so_luong"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return map;
    }

    // Lấy danh sách 3 hoạt động cập nhật sự cố mới nhất
    public List<SuCo> getTop3CapNhat() {
        List<SuCo> list = new ArrayList<>();
        String query = "SELECT sc.su_co_id, sc.tieu_de, sc.trang_thai, sc.ngay_gui " +
                "FROM su_co sc " +
                "ORDER BY sc.ngay_gui DESC LIMIT 3";
        try {
            Connection conn = new DBContext().getConnection();
            PreparedStatement ps = conn.prepareStatement(query);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                SuCo sc = new SuCo();
                sc.setSuCoId(rs.getInt("su_co_id"));
                sc.setTieuDe(rs.getString("tieu_de"));
                sc.setTrangThai(rs.getString("trang_thai"));
                sc.setNgayGui(rs.getTimestamp("ngay_gui"));
                list.add(sc);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // Lấy lịch sử sự cố của nhân viên theo đúng tổ và theo trạng thái lọc
    public List<SuCo> getAllSuCoHistoryForStaff(int taiKhoanId, String filter) {
        List<SuCo> list = new ArrayList<>();
        String query = "SELECT sc.su_co_id, sc.tieu_de, sc.mo_ta, sc.ghi_chu_xu_ly, sc.muc_do, sc.trang_thai, sc.ngay_gui, " +
                "p.ma_phong, p.toa_nha, tk.ho_ten, tk.so_dien_thoai " +
                "FROM su_co sc " +
                "JOIN loai_su_co lsc ON sc.loai_su_co_id = lsc.loai_su_co_id " +
                "JOIN nhan_vien nv ON lsc.to_id = nv.to_id " +
                "LEFT JOIN phong p ON sc.phong_id = p.phong_id " +
                "LEFT JOIN sinh_vien sv ON sc.sinh_vien_id = sv.sinh_vien_id " +
                "LEFT JOIN tai_khoan tk ON sv.tai_khoan_id = tk.tai_khoan_id " +
                "WHERE nv.tai_khoan_id = ? AND (sc.nhan_vien_id = nv.nhan_vien_id OR (sc.nhan_vien_id IS NULL AND sc.trang_thai <> 'Chờ xử lý')) ";

        if ("pending".equals(filter)) {
            query += "AND sc.trang_thai = 'Chờ xử lý' ";
        } else if ("processing".equals(filter)) {
            query += "AND sc.trang_thai = 'Đang xử lý' ";
        } else if ("done".equals(filter)) {
            query += "AND sc.trang_thai = 'Đã hoàn thành' ";
        }
        query += "ORDER BY sc.ngay_gui DESC";

        try {
            conn = new DBContext().getConnection();
            ps = conn.prepareStatement(query);
            ps.setInt(1, taiKhoanId);
            rs = ps.executeQuery();
            while (rs.next()) {
                SuCo sc = new SuCo();
                sc.setSuCoId(rs.getInt("su_co_id"));
                sc.setTieuDe(rs.getString("tieu_de"));
                sc.setMoTa(rs.getString("mo_ta"));
                sc.setGhiChuKyThuat(rs.getString("ghi_chu_xu_ly"));
                sc.setMucDo(rs.getString("muc_do"));
                sc.setTrangThai(rs.getString("trang_thai"));
                sc.setNgayGui(rs.getTimestamp("ngay_gui"));

                String phong = rs.getString("ma_phong") != null ? rs.getString("ma_phong") : "N/A";
                String toa = rs.getString("toa_nha") != null ? rs.getString("toa_nha") : "N/A";
                sc.setViTriPhong("Ph\u00f2ng " + phong + " - T\u00f2a " + toa);
                sc.setTenNguoiGui(rs.getString("ho_ten") != null ? rs.getString("ho_ten") : "Không rõ");
                sc.setSoDienThoai(rs.getString("so_dien_thoai") != null ? rs.getString("so_dien_thoai") : "Không có");

                list.add(sc);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // Lấy toàn bộ danh sách sự cố cho Admin (Có tích hợp bộ lọc trạng thái)
    public List<SuCo> getAllSuCoForAdmin(String filter) {
        List<SuCo> list = new ArrayList<>();
        String query = "SELECT sc.su_co_id, sc.tieu_de, sc.mo_ta, sc.ghi_chu_xu_ly, sc.muc_do, sc.trang_thai, sc.ngay_gui, " +
                "p.ma_phong, p.toa_nha, tk.ho_ten, tk.so_dien_thoai " +
                "FROM su_co sc " +
                "LEFT JOIN phong p ON sc.phong_id = p.phong_id " +
                "LEFT JOIN sinh_vien sv ON sc.sinh_vien_id = sv.sinh_vien_id " +
                "LEFT JOIN tai_khoan tk ON sv.tai_khoan_id = tk.tai_khoan_id WHERE 1=1 ";

        if ("pending".equals(filter)) {
            query += "AND sc.trang_thai = 'Chờ xử lý' ";
        } else if ("processing".equals(filter)) {
            query += "AND sc.trang_thai = 'Đang xử lý' ";
        } else if ("done".equals(filter)) {
            query += "AND sc.trang_thai = 'Đã hoàn thành' ";
        }
        query += "ORDER BY sc.ngay_gui DESC";

        try {
            conn = new DBContext().getConnection();
            ps = conn.prepareStatement(query);
            rs = ps.executeQuery();
            while (rs.next()) {
                SuCo sc = new SuCo();
                sc.setSuCoId(rs.getInt("su_co_id"));
                sc.setTieuDe(rs.getString("tieu_de"));
                sc.setMoTa(rs.getString("mo_ta"));
                sc.setGhiChuKyThuat(rs.getString("ghi_chu_xu_ly"));
                sc.setMucDo(rs.getString("muc_do"));
                sc.setTrangThai(rs.getString("trang_thai"));
                sc.setNgayGui(rs.getTimestamp("ngay_gui"));

                String phong = rs.getString("ma_phong") != null ? rs.getString("ma_phong") : "N/A";
                String toa = rs.getString("toa_nha") != null ? rs.getString("toa_nha") : "N/A";
                sc.setViTriPhong("Ph\u00f2ng " + phong + " - T\u00f2a " + toa);
                sc.setTenNguoiGui(rs.getString("ho_ten") != null ? rs.getString("ho_ten") : "Không rõ");
                sc.setSoDienThoai(rs.getString("so_dien_thoai") != null ? rs.getString("so_dien_thoai") : "Không có");

                list.add(sc);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // 1. Chỉ lấy các sự cố "Chờ xử lý" cho trang chủ Admin
    public List<SuCo> getPendingSuCoForAdmin() {
        List<SuCo> list = new ArrayList<>();
        String query = "SELECT sc.su_co_id, sc.tieu_de, sc.mo_ta, sc.ghi_chu_xu_ly, sc.muc_do, sc.trang_thai, sc.ngay_gui, " +
                "p.ma_phong, p.toa_nha, tk.ho_ten, tk.so_dien_thoai, lsc.to_id " +
                "FROM su_co sc " +
                "JOIN loai_su_co lsc ON sc.loai_su_co_id = lsc.loai_su_co_id " +
                "LEFT JOIN phong p ON sc.phong_id = p.phong_id " +
                "LEFT JOIN sinh_vien sv ON sc.sinh_vien_id = sv.sinh_vien_id " +
                "LEFT JOIN tai_khoan tk ON sv.tai_khoan_id = tk.tai_khoan_id " +
                "WHERE sc.trang_thai = 'Chờ xử lý' " +
                "ORDER BY sc.ngay_gui DESC";
        try {
            conn = new DBContext().getConnection();
            ps = conn.prepareStatement(query);
            rs = ps.executeQuery();
            while (rs.next()) {
                SuCo sc = new SuCo();
                sc.setSuCoId(rs.getInt("su_co_id"));
                sc.setTieuDe(rs.getString("tieu_de"));
                sc.setMoTa(rs.getString("mo_ta"));
                sc.setGhiChuKyThuat(rs.getString("ghi_chu_xu_ly"));
                sc.setMucDo(rs.getString("muc_do"));
                sc.setTrangThai(rs.getString("trang_thai"));
                sc.setNgayGui(rs.getTimestamp("ngay_gui"));

                String phong = rs.getString("ma_phong") != null ? rs.getString("ma_phong") : "N/A";
                String toa = rs.getString("toa_nha") != null ? rs.getString("toa_nha") : "N/A";
                sc.setViTriPhong("Ph\u00f2ng " + phong + " - T\u00f2a " + toa);
                sc.setTenNguoiGui(rs.getString("ho_ten") != null ? rs.getString("ho_ten") : "Không rõ");
                sc.setSoDienThoai(rs.getString("so_dien_thoai") != null ? rs.getString("so_dien_thoai") : "Không có");

                sc.setToId(rs.getInt("to_id"));

                list.add(sc);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // 2. Lấy danh sách nhân viên thuộc đúng tổ kỹ thuật (to_id)
    public List<TaiKhoan> getStaffByTeam(int toId) {
        List<TaiKhoan> list = new ArrayList<>();
        String query = "SELECT tk.tai_khoan_id, tk.ho_ten, tk.so_dien_thoai FROM tai_khoan tk " +
                "JOIN nhan_vien nv ON tk.tai_khoan_id = nv.tai_khoan_id " +
                "WHERE nv.to_id = ?";
        try {
            conn = new DBContext().getConnection();
            ps = conn.prepareStatement(query);
            ps.setInt(1, toId);
            rs = ps.executeQuery();
            while (rs.next()) {
                TaiKhoan nv = new TaiKhoan();
                nv.setTaiKhoanId(rs.getInt("tai_khoan_id"));
                nv.setHoTen(rs.getString("ho_ten"));
                nv.setSoDienThoai(rs.getString("so_dien_thoai"));
                list.add(nv);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // Đếm số sự cố đã hoàn thành trong tháng này theo đúng tổ của nhân viên
    public int countCompletedIssuesThisMonth(int taiKhoanId) {
        int count = 0;
        String query = "SELECT COUNT(*) FROM su_co sc " +
                "JOIN loai_su_co lsc ON sc.loai_su_co_id = lsc.loai_su_co_id " +
                "JOIN nhan_vien nv ON lsc.to_id = nv.to_id " +
                "WHERE nv.tai_khoan_id = ? AND (sc.nhan_vien_id = nv.nhan_vien_id OR (sc.nhan_vien_id IS NULL AND sc.trang_thai <> 'Chờ xử lý')) " +
                "AND sc.trang_thai = 'Đã hoàn thành' " +
                "AND MONTH(sc.ngay_cap_nhat) = MONTH(CURRENT_DATE()) " +
                "AND YEAR(sc.ngay_cap_nhat) = YEAR(CURRENT_DATE())";
        try {
            conn = new DBContext().getConnection();
            ps = conn.prepareStatement(query);
            ps.setInt(1, taiKhoanId);
            rs = ps.executeQuery();
            if (rs.next()) {
                count = rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return count;
    }

    public Map<String, Integer> getCountByLoaiSuCo() {
        Map<String, Integer> result = new LinkedHashMap<>();
        String sql = "SELECT lsc.ten_loai AS ten_loai, COUNT(sc.su_co_id) AS so_luong "
                + "FROM loai_su_co lsc "
                + "LEFT JOIN su_co sc ON lsc.loai_su_co_id = sc.loai_su_co_id "
                + "GROUP BY lsc.loai_su_co_id, lsc.ten_loai "
                + "ORDER BY so_luong DESC, lsc.ten_loai ASC";

        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                String loai = rs.getString("ten_loai");
                result.put(loai != null ? loai : "Khác", rs.getInt("so_luong"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return result;
    }

    public Map<String, Integer> getCountByTrangThai() {
        Map<String, Integer> result = new LinkedHashMap<>();
        String sql = "SELECT trang_thai, COUNT(*) AS so_luong "
                + "FROM su_co "
                + "GROUP BY trang_thai "
                + "ORDER BY so_luong DESC";

        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                String rawStatus = rs.getString("trang_thai");
                String label = mapTrangThaiLabel(rawStatus);
                result.put(label, rs.getInt("so_luong"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return result;
    }

    private String mapTrangThaiLabel(String status) {
        if (status == null || status.trim().isEmpty()) {
            return "Không xác định";
        }
        String normalized = status.trim().toUpperCase();
        if ("CHO_XU_LY".equals(normalized) || "CHỜ XỬ LÝ".equals(normalized)) {
            return "Chờ xử lý";
        }
        if ("DANG_XU_LY".equals(normalized) || "ĐANG XỬ LÝ".equals(normalized)) {
            return "Đang xử lý";
        }
        if ("HOAN_THANH".equals(normalized) || "HOÀN THÀNH".equals(normalized) || "ĐÃ HOÀN THÀNH".equals(normalized)) {
            return "Hoàn thành";
        }
        if ("HUY".equals(normalized) || "ĐÃ HỦY".equals(normalized)) {
            return "Đã hủy";
        }
        return status;
    }

    // 1. Đếm số lượng sự cố theo loại trong khoảng thời gian [from, to)
    public Map<String, Integer> getCountByLoaiSuCo(java.sql.Timestamp from, java.sql.Timestamp to) {
        Map<String, Integer> result = new LinkedHashMap<>();
        String sql = "SELECT lsc.ten_loai AS ten_loai, COUNT(sc.su_co_id) AS so_luong "
                + "FROM loai_su_co lsc "
                + "LEFT JOIN su_co sc ON lsc.loai_su_co_id = sc.loai_su_co_id "
                + "AND sc.ngay_gui >= ? AND sc.ngay_gui < ? "
                + "GROUP BY lsc.loai_su_co_id, lsc.ten_loai "
                + "ORDER BY so_luong DESC, lsc.ten_loai ASC";

        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setTimestamp(1, from);
            ps.setTimestamp(2, to);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String loai = rs.getString("ten_loai");
                    result.put(loai != null ? loai : "Khác", rs.getInt("so_luong"));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return result;
    }

    // 2. Đếm số lượng sự cố theo trạng thái trong khoảng thời gian [from, to)
    public Map<String, Integer> getCountByTrangThai(java.sql.Timestamp from, java.sql.Timestamp to) {
        Map<String, Integer> result = new LinkedHashMap<>();
        String sql = "SELECT trang_thai, COUNT(*) AS so_luong "
                + "FROM su_co "
                + "WHERE ngay_gui >= ? AND ngay_gui < ? "
                + "GROUP BY trang_thai";

        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setTimestamp(1, from);
            ps.setTimestamp(2, to);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String label = mapTrangThaiLabel(rs.getString("trang_thai"));
                    result.put(label, result.getOrDefault(label, 0) + rs.getInt("so_luong"));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return result;
    }

    // 3. Lấy danh sách sự cố gần đây trong khoảng thời gian [from, to) (có kèm loại sự cố & thông tin chi tiết)
    public List<SuCo> getRecentSuCoForAdmin(java.sql.Timestamp from, java.sql.Timestamp to, int limit) {
        List<SuCo> list = new ArrayList<>();
        String sql = "SELECT sc.su_co_id, sc.tieu_de, sc.mo_ta, sc.ghi_chu_xu_ly, sc.muc_do, sc.trang_thai, sc.ngay_gui, "
                + "lsc.ten_loai, p.ma_phong, p.toa_nha, tk.ho_ten, tk.so_dien_thoai "
                + "FROM su_co sc "
                + "LEFT JOIN loai_su_co lsc ON sc.loai_su_co_id = lsc.loai_su_co_id "
                + "LEFT JOIN phong p ON sc.phong_id = p.phong_id "
                + "LEFT JOIN sinh_vien sv ON sc.sinh_vien_id = sv.sinh_vien_id "
                + "LEFT JOIN tai_khoan tk ON sv.tai_khoan_id = tk.tai_khoan_id "
                + "WHERE sc.ngay_gui >= ? AND sc.ngay_gui < ? "
                + "ORDER BY sc.ngay_gui DESC LIMIT ?";

        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setTimestamp(1, from);
            ps.setTimestamp(2, to);
            ps.setInt(3, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    SuCo sc = new SuCo();
                    sc.setSuCoId(rs.getInt("su_co_id"));
                    sc.setTieuDe(rs.getString("tieu_de"));
                    sc.setMoTa(rs.getString("mo_ta"));
                    sc.setGhiChuKyThuat(rs.getString("ghi_chu_xu_ly"));
                    sc.setMucDo(rs.getString("muc_do"));
                    sc.setTrangThai(rs.getString("trang_thai"));
                    sc.setNgayGui(rs.getTimestamp("ngay_gui"));
                    sc.setTenLoaiSuCo(rs.getString("ten_loai") != null ? rs.getString("ten_loai") : "Khác");

                    String phong = rs.getString("ma_phong") != null ? rs.getString("ma_phong") : "N/A";
                    String toa = rs.getString("toa_nha") != null ? rs.getString("toa_nha") : "N/A";
                    sc.setViTriPhong("Phòng " + phong + " - Tòa " + toa);
                    sc.setTenNguoiGui(rs.getString("ho_ten") != null ? rs.getString("ho_ten") : "Không rõ");
                    sc.setSoDienThoai(rs.getString("so_dien_thoai") != null ? rs.getString("so_dien_thoai") : "Không có");
                    list.add(sc);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

}