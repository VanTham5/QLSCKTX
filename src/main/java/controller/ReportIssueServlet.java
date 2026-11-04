package controller;

import dao.SuCoDAO;
import model.SuCo;
import model.TaiKhoan;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

@WebServlet(name = "ReportIssueServlet", urlPatterns = {"/report-issue"})
public class ReportIssueServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Bắt buộc set UTF-8 để lưu tiếng Việt có dấu không bị lỗi font
        request.setCharacterEncoding("UTF-8");

        // 2. Kiểm tra đăng nhập
        HttpSession session = request.getSession();
        TaiKhoan acc = (TaiKhoan) session.getAttribute("acc");
        if (acc == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        // 3. Lấy dữ liệu người dùng nhập từ Form
        String tieuDe = request.getParameter("tieuDe");
        int loaiSuCoId = Integer.parseInt(request.getParameter("loaiSuCoId"));
        String mucDo = request.getParameter("mucDo");
        String moTa = request.getParameter("moTa");

        // 4. Truy vấn nhanh để lấy sinh_vien_id và phong_id từ tài khoản đang đăng nhập
        int sinhVienId = 0;
        int phongId = 0;
        try {
            Connection conn = new context.DBContext().getConnection();
            PreparedStatement ps = conn.prepareStatement("SELECT sinh_vien_id, phong_id FROM sinh_vien WHERE tai_khoan_id = ?");
            ps.setInt(1, acc.getTaiKhoanId());
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                sinhVienId = rs.getInt("sinh_vien_id");
                phongId = rs.getInt("phong_id");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        // 5. Đóng gói dữ liệu vào đối tượng SuCo
        SuCo sc = new SuCo();
        sc.setSinhVienId(sinhVienId);
        sc.setPhongId(phongId);
        sc.setLoaiSuCoId(loaiSuCoId);
        sc.setTieuDe(tieuDe);
        sc.setMoTa(moTa);
        sc.setMucDo(mucDo);

        // 6. Gọi DAO để thêm vào Database
        SuCoDAO dao = new SuCoDAO();
        boolean isSuccess = dao.insertSuCo(sc);

        // 7. Chuyển hướng về lại trang chủ của Sinh viên
        // (Thực tế nên truyền thêm thông báo thành công, nhưng tạm thời redirect thẳng để chạy luồng)
        response.sendRedirect(request.getContextPath() + "/student-home");
    }
}