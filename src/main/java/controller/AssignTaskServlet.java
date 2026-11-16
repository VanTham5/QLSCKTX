package controller;

import dao.SuCoDAO;
import model.TaiKhoan;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet(name = "AssignTaskServlet", urlPatterns = {"/assign-task"})
public class AssignTaskServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        TaiKhoan acc = (TaiKhoan) session.getAttribute("acc");

        // Kiểm tra bảo mật: Chỉ Admin mới được phân công
        if (acc == null || !"ADMIN".equals(acc.getVaiTro())) {
            response.sendRedirect("login.jsp");
            return;
        }

        try {
            // Lấy mã sự cố và mã nhân viên được chọn từ Modal phân công
            int suCoId = Integer.parseInt(request.getParameter("suCoId"));
            int nhanVienId = Integer.parseInt(request.getParameter("nhanVienId"));

            SuCoDAO dao = new SuCoDAO();

            // 1. Cập nhật trạng thái sự cố thành "Đang xử lý"
            dao.updateTrangThaiSuCo(suCoId, "Đang xử lý");

            // (Tùy chọn) Nếu database của bạn có cột lưu nhân viên nhận việc, bạn có thể gọi hàm gán nhân viên ở đây:
            // dao.assignStaffToIssue(suCoId, nhanVienId);

        } catch (Exception e) {
            e.printStackTrace();
        }

        // Sau khi phân công thành công, load lại trang chủ Admin
        response.sendRedirect(request.getContextPath() + "/admin-home");
    }
}