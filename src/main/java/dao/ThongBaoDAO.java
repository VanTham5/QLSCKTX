package dao;

import context.DBContext;
import model.ThongBao;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class ThongBaoDAO {
    public List<ThongBao> getAllThongBao() {
        List<ThongBao> list = new ArrayList<>();
        String query = "SELECT * FROM thong_bao ORDER BY ngay_tao DESC";
        try {
            Connection conn = new DBContext().getConnection();
            PreparedStatement ps = conn.prepareStatement(query);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                ThongBao tb = new ThongBao();
                tb.setId(rs.getInt("thong_bao_id"));
                tb.setTieuDe(rs.getString("tieu_de"));
                tb.setNoiDung(rs.getString("noi_dung"));
                tb.setNgayTao(rs.getTimestamp("ngay_tao"));
                list.add(tb);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // Hàm dành riêng cho Admin: Thêm thông báo mới vào CSDL
    public boolean insertThongBao(String tieuDe, String noiDung) {
        String query = "INSERT INTO thong_bao (tieu_de, noi_dung) VALUES (?, ?)";
        try {
            java.sql.Connection conn = new context.DBContext().getConnection();
            java.sql.PreparedStatement ps = conn.prepareStatement(query);
            ps.setString(1, tieuDe);
            ps.setString(2, noiDung);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
}