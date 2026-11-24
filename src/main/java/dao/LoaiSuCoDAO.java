package dao;

import context.DBContext;
import model.LoaiSuCo;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class LoaiSuCoDAO {

    // 1. Lấy danh sách toàn bộ loại sự cố kèm theo tên tổ phụ trách
    public List<LoaiSuCo> getAllLoaiSuCo() {
        List<LoaiSuCo> list = new ArrayList<>();
        String query = "SELECT lsc.loai_su_co_id, lsc.ten_loai, lsc.to_id, lsc.mo_ta, tnv.ten_to " +
                "FROM loai_su_co lsc " +
                "LEFT JOIN to_nhan_vien tnv ON lsc.to_id = tnv.to_id " +
                "ORDER BY lsc.loai_su_co_id DESC";
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(query);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                LoaiSuCo lsc = new LoaiSuCo();
                lsc.setLoaiSuCoId(rs.getInt("loai_su_co_id"));
                lsc.setTenLoai(rs.getString("ten_loai"));
                lsc.setToId(rs.getInt("to_id"));
                lsc.setMoTota(rs.getString("mo_ta"));
                lsc.setTenTo(rs.getString("ten_to") != null ? rs.getString("ten_to") : "Chưa phân tổ");
                list.add(lsc);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // 2. Thêm mới loại sự cố
    public boolean insertLoaiSuCo(String tenLoai, int toId, String moTa) {
        String query = "INSERT INTO loai_su_co (ten_loai, to_id, mo_ta) VALUES (?, ?, ?)";
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setString(1, tenLoai);
            ps.setInt(2, toId);
            ps.setString(3, moTa);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // 3. Cập nhật loại sự cố
    public boolean updateLoaiSuCo(int id, String tenLoai, int toId, String moTa) {
        String query = "UPDATE loai_su_co SET ten_loai = ?, to_id = ?, mo_ta = ? WHERE loai_su_co_id = ?";
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setString(1, tenLoai);
            ps.setInt(2, toId);
            ps.setString(3, moTa);
            ps.setInt(4, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // 4. Xóa loại sự cố
    public boolean deleteLoaiSuCo(int id) {
        String query = "DELETE FROM loai_su_co WHERE loai_su_co_id = ?";
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
}