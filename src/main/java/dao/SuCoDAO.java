package dao;

import context.DBContext;
import model.SuCo;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class SuCoDAO implements ISuCoDAO {
    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    // 1. Lấy danh sách sự cố cho Nhân Viên / Admin (Kèm thông tin Phòng và SĐT)
    public List<SuCo> getAllSuCoForStaff() {
        List<SuCo> list = new ArrayList<>();
        /*
           Sử dụng LEFT JOIN để nối 4 bảng: su_co, phong, sinh_vien, tai_khoan.
           Sắp xếp ưu tiên: Chờ xử lý -> Đang xử lý -> Đã hoàn thành.
        */
        String query = "SELECT sc.su_co_id, sc.tieu_de, sc.muc_do, sc.trang_thai, sc.ngay_gui, " +
                "p.ma_phong, p.toa_nha, " +
                "tk.ho_ten, tk.so_dien_thoai " +
                "FROM su_co sc " +
                "LEFT JOIN phong p ON sc.phong_id = p.phong_id " +
                "LEFT JOIN sinh_vien sv ON sc.sinh_vien_id = sv.sinh_vien_id " +
                "LEFT JOIN tai_khoan tk ON sv.tai_khoan_id = tk.tai_khoan_id " +
                "ORDER BY FIELD(sc.trang_thai, 'Chờ xử lý', 'Đang xử lý', 'Đã hoàn thành'), sc.ngay_gui DESC";
        try {
            conn = new DBContext().getConnection();
            ps = conn.prepareStatement(query);
            rs = ps.executeQuery();
            while (rs.next()) {
                SuCo sc = new SuCo();
                sc.setSuCoId(rs.getInt("su_co_id"));
                sc.setTieuDe(rs.getString("tieu_de"));
                sc.setMucDo(rs.getString("muc_do"));
                sc.setTrangThai(rs.getString("trang_thai"));
                sc.setNgayGui(rs.getTimestamp("ngay_gui"));

                // Gộp thông tin phòng và tòa nhà thành 1 chuỗi để hiển thị
                String phong = rs.getString("ma_phong") != null ? rs.getString("ma_phong") : "N/A";
                String toa = rs.getString("toa_nha") != null ? rs.getString("toa_nha") : "N/A";
                sc.setViTriPhong("Phòng " + phong + " - Tòa " + toa);

                // Hứng tên và số điện thoại từ bảng tai_khoan
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
    public void updateTrangThaiSuCo(int suCoId, String trangThaiMoi, int nhanVienId) {
        String query = "UPDATE su_co SET trang_thai = ?, nhan_vien_id = ? WHERE su_co_id = ?";
        try {
            conn = new DBContext().getConnection();
            ps = conn.prepareStatement(query);
            ps.setString(1, trangThaiMoi);
            ps.setInt(2, nhanVienId);
            ps.setInt(3, suCoId);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    // --- CÁC HÀM DÀNH CHO LUỒNG SINH VIÊN ---

    // 3. Đếm số lượng sự cố theo trạng thái (hoặc đếm tất cả nếu status = null)
    public int countIssueByStatus(int tkId, String status) {
        int count = 0;
        // Kết nối bảng su_co với sinh_vien để lọc theo tai_khoan_id
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

    // 4. Lấy danh sách 5 sự cố mới nhất của sinh viên đó
    public List<SuCo> getTop5RecentIssues(int tkId) {
        List<SuCo> list = new ArrayList<>();
        String query = "SELECT sc.su_co_id, sc.tieu_de, sc.muc_do, sc.trang_thai, sc.ngay_gui, " +
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
                sc.setMucDo(rs.getString("muc_do"));
                sc.setTrangThai(rs.getString("trang_thai"));
                sc.setNgayGui(rs.getTimestamp("ngay_gui"));

                String phong = rs.getString("ma_phong") != null ? rs.getString("ma_phong") : "N/A";
                String toa = rs.getString("toa_nha") != null ? rs.getString("toa_nha") : "N/A";
                sc.setViTriPhong("Phòng " + phong + " - Tòa " + toa);

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

    @Override
    public boolean insertSuCo(SuCo sc) {
        // Lấy thời gian hiện tại và mặc định trạng thái là 'Chờ xử lý'
        String query = "INSERT INTO su_co (sinh_vien_id, phong_id, loai_su_co_id, tieu_de, mo_ta, muc_do, trang_thai, ngay_gui) " +
                "VALUES (?, ?, ?, ?, ?, ?, 'Chờ xử lý', CURRENT_TIMESTAMP)";
        try {
            conn = new context.DBContext().getConnection();
            ps = conn.prepareStatement(query);
            ps.setInt(1, sc.getSinhVienId());
            ps.setInt(2, sc.getPhongId());
            ps.setInt(3, sc.getLoaiSuCoId());
            ps.setString(4, sc.getTieuDe());
            ps.setString(5, sc.getMoTa());
            ps.setString(6, sc.getMucDo());

            int result = ps.executeUpdate();
            return result > 0; // Trả về true nếu thêm thành công
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
            return result > 0; // Trả về true nếu xóa thành công
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }


    // Lấy toàn bộ lịch sử báo cáo của Sinh viên (Có kèm bộ lọc trạng thái)
    public List<SuCo> getHistoryIssues(int tkId, String filter) {
        List<SuCo> list = new ArrayList<>();

        // Câu lệnh gốc mặc định lấy tất cả
        String query = "SELECT sc.su_co_id, sc.tieu_de, sc.mo_ta, sc.muc_do, sc.trang_thai, sc.ngay_gui " +
                "FROM su_co sc " +
                "JOIN sinh_vien sv ON sc.sinh_vien_id = sv.sinh_vien_id " +
                "WHERE sv.tai_khoan_id = ? ";

        // Kiểm tra bộ lọc và nối thêm điều kiện vào SQL
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
                sc.setMucDo(rs.getString("muc_do"));
                sc.setTrangThai(rs.getString("trang_thai"));
                sc.setNgayGui(rs.getTimestamp("ngay_gui"));
                list.add(sc);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
}
