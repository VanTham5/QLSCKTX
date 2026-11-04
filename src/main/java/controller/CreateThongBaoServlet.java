package controller;

import dao.ThongBaoDAO;
import model.TaiKhoan;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet(name = "CreateThongBaoServlet", urlPatterns = {"/create-thongbao"})
public class CreateThongBaoServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        TaiKhoan acc = (TaiKhoan) session.getAttribute("acc");

        // BẢO MẬT: Chỉ có ADMIN mới được phép thực hiện hành động này
        if (acc == null || !"ADMIN".equals(acc.getVaiTro())) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        // Lấy dữ liệu từ Form của Admin
        String tieuDe = request.getParameter("tieuDe");
        String noiDung = request.getParameter("noiDung");

        // Lưu vào CSDL
        ThongBaoDAO dao = new ThongBaoDAO();
        dao.insertThongBao(tieuDe, noiDung);

        // Đăng xong thì load lại trang Admin
        response.sendRedirect(request.getContextPath() + "/admin-home");
    }
}