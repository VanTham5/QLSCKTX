package dao;

import context.DBContext;
import model.SuCo;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class SuCoDAO {

    // Lấy 5 sự cố gần nhất của 1 sinh viên (thông qua tai_khoan_id)
    public List<SuCo> getTop5RecentIssues(int taiKhoanId) {
        List<SuCo> list = new ArrayList<>();
        String query = "SELECT sc.su_co_id, sc.tieu_de, l.ten_loai, CONCAT('Phòng ', p.ma_phong, ' - Tòa ', p.toa_nha) AS vi_tri, " +
                "sc.muc_do, DATE_FORMAT(sc.ngay_gui, '%d/%m/%Y') AS ngay, sc.trang_thai " +
                "FROM SU_CO sc " +
                "JOIN SINH_VIEN sv ON sc.sinh_vien_id = sv.sinh_vien_id " +
                "JOIN LOAI_SU_CO l ON sc.loai_su_co_id = l.loai_su_co_id " +
                "JOIN PHONG p ON sc.phong_id = p.phong_id " +
                "WHERE sv.tai_khoan_id = ? " +
                "ORDER BY sc.ngay_gui DESC LIMIT 5";
        try {
            Connection conn = new DBContext().getConnection();
            PreparedStatement ps = conn.prepareStatement(query);
            ps.setInt(1, taiKhoanId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(new SuCo(
                        "#SC00" + rs.getInt("su_co_id"),
                        rs.getString("tieu_de"),
                        rs.getString("ten_loai"),
                        rs.getString("vi_tri"),
                        rs.getString("muc_do"),
                        rs.getString("ngay"),
                        rs.getString("trang_thai")
                ));
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    // Đếm tổng số sự cố theo trạng thái
    public int countIssueByStatus(int taiKhoanId, String status) {
        String query = "SELECT COUNT(*) FROM SU_CO sc JOIN SINH_VIEN sv ON sc.sinh_vien_id = sv.sinh_vien_id WHERE sv.tai_khoan_id = ?";
        if (status != null) query += " AND sc.trang_thai = ?";

        try {
            Connection conn = new DBContext().getConnection();
            PreparedStatement ps = conn.prepareStatement(query);
            ps.setInt(1, taiKhoanId);
            if (status != null) ps.setString(2, status);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
        } catch (Exception e) { e.printStackTrace(); }
        return 0;
    }
}