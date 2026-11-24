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
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(query);
             ResultSet rs = ps.executeQuery()) {
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

    public boolean insertThongBao(String tieuDe, String noiDung) {
        return insertThongBao(tieuDe, noiDung, null);
    }

    public boolean insertThongBao(String tieuDe, String noiDung, Integer nguoiTaoId) {
        String query = nguoiTaoId == null
                ? "INSERT INTO thong_bao (tieu_de, noi_dung) VALUES (?, ?)"
                : "INSERT INTO thong_bao (tieu_de, noi_dung, nguoi_tao_id) VALUES (?, ?, ?)";
        try (Connection connection = new DBContext().getConnection();
             PreparedStatement statement = connection.prepareStatement(query)) {
            statement.setString(1, tieuDe);
            statement.setString(2, noiDung);
            if (nguoiTaoId != null) {
                statement.setInt(3, nguoiTaoId);
            }
            return statement.executeUpdate() == 1;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}