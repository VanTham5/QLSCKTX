package dao;

import context.DBContext;
import model.Phong;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class PhongDAO {

    // 1. Lấy danh sách toàn bộ tòa nhà
    public List<String> getAllToaNha() {
        List<String> list = new ArrayList<>();
        String query = "SELECT DISTINCT toa_nha FROM phong WHERE toa_nha IS NOT NULL AND toa_nha <> '' ORDER BY toa_nha";
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(query);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(rs.getString("toa_nha"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // 2. Lấy danh sách phòng theo tòa nhà (hoặc tất cả) kèm số lượng sinh viên đang ở
    public List<Phong> getRoomsByBuilding(String toaNha) {
        List<Phong> list = new ArrayList<>();
        String query = "SELECT p.phong_id, p.ma_phong, p.toa_nha, p.tang, p.loai_phong, p.trang_thai, " +
                "COUNT(sv.sinh_vien_id) AS so_sinh_vien " +
                "FROM phong p " +
                "LEFT JOIN sinh_vien sv ON p.phong_id = sv.phong_id ";

        boolean filterBuilding = toaNha != null && !toaNha.isEmpty() && !"all".equalsIgnoreCase(toaNha);
        if (filterBuilding) {
            query += "WHERE p.toa_nha = ? ";
        }
        query += "GROUP BY p.phong_id, p.ma_phong, p.toa_nha, p.tang, p.loai_phong, p.trang_thai " +
                "ORDER BY p.toa_nha, p.tang, p.ma_phong";

        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            if (filterBuilding) {
                ps.setString(1, toaNha);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Phong p = new Phong();
                    p.setPhongId(rs.getInt("phong_id"));
                    p.setMaPhong(rs.getString("ma_phong"));
                    p.setToaNha(rs.getString("toa_nha"));
                    p.setTang(rs.getInt("tang"));
                    p.setLoaiPhong(rs.getString("loai_phong"));
                    p.setTrangThai(rs.getString("trang_thai"));
                    p.setSoSinhVien(rs.getInt("so_sinh_vien"));
                    list.add(p);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // 3. Thêm phòng mới
    public boolean addPhong(String maPhong, String toaNha, int tang, String loaiPhong, String trangThai) {
        String query = "INSERT INTO phong (ma_phong, toa_nha, tang, loai_phong, trang_thai) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setString(1, maPhong.trim());
            ps.setString(2, toaNha.trim());
            ps.setInt(3, tang);
            ps.setString(4, loaiPhong.trim());
            ps.setString(5, trangThai.trim());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // 4. Cập nhật thông tin phòng
    public boolean updatePhong(int phongId, String maPhong, String toaNha, int tang, String loaiPhong, String trangThai) {
        String query = "UPDATE phong SET ma_phong = ?, toa_nha = ?, tang = ?, loai_phong = ?, trang_thai = ? WHERE phong_id = ?";
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setString(1, maPhong.trim());
            ps.setString(2, toaNha.trim());
            ps.setInt(3, tang);
            ps.setString(4, loaiPhong.trim());
            ps.setString(5, trangThai.trim());
            ps.setInt(6, phongId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // 5. Xóa phòng theo ID
    public boolean deletePhong(int phongId) {
        String query = "DELETE FROM phong WHERE phong_id = ?";
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setInt(1, phongId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // 6. Lấy danh sách sinh viên trong phòng (mỗi phần tử là mảng String[5]: [maSV, hoTen, lop, khoa, sdt])
    public List<String[]> getStudentsByPhongId(int phongId) {
        List<String[]> list = new ArrayList<>();
        String query = "SELECT sv.ma_sinh_vien, tk.ho_ten, sv.lop, sv.khoa, tk.so_dien_thoai " +
                "FROM sinh_vien sv " +
                "JOIN tai_khoan tk ON sv.tai_khoan_id = tk.tai_khoan_id " +
                "WHERE sv.phong_id = ? " +
                "ORDER BY sv.ma_sinh_vien";
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setInt(1, phongId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String[] sv = new String[5];
                    sv[0] = rs.getString("ma_sinh_vien") != null ? rs.getString("ma_sinh_vien") : "---";
                    sv[1] = rs.getString("ho_ten") != null ? rs.getString("ho_ten") : "Chưa cập nhật";
                    sv[2] = rs.getString("lop") != null ? rs.getString("lop") : "---";
                    sv[3] = rs.getString("khoa") != null ? rs.getString("khoa") : "---";
                    sv[4] = rs.getString("so_dien_thoai") != null ? rs.getString("so_dien_thoai") : "Chưa cập nhật";
                    list.add(sv);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
}