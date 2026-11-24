package dao;

import context.DBContext;
import model.ThongBao;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class ThongBaoDAO {
    public List<ThongBao> getNoticeBatch(int beforeId, int limit) throws Exception {
        List<ThongBao> list = new ArrayList<>();
        String query = "SELECT n.thong_bao_id, n.tieu_de, n.noi_dung, n.ngay_tao FROM thong_bao n ";
        if (beforeId > 0) {
            query += "JOIN thong_bao c ON c.thong_bao_id = ? "
                    + "WHERE n.ngay_tao < c.ngay_tao "
                    + "OR (n.ngay_tao IS NULL AND c.ngay_tao IS NOT NULL) "
                    + "OR ((n.ngay_tao <=> c.ngay_tao) AND n.thong_bao_id < c.thong_bao_id) ";
        }
        query += "ORDER BY n.ngay_tao DESC, n.thong_bao_id DESC LIMIT ?";

        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            int index = 1;
            if (beforeId > 0) {
                ps.setInt(index++, beforeId);
            }
            ps.setInt(index, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ThongBao tb = new ThongBao();
                    tb.setId(rs.getInt("thong_bao_id"));
                    tb.setTieuDe(rs.getString("tieu_de"));
                    tb.setNoiDung(rs.getString("noi_dung"));
                    tb.setNgayTao(rs.getTimestamp("ngay_tao"));
                    list.add(tb);
                }
            }
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