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

@WebServlet(name = "UpdateStatusServlet", urlPatterns = {"/update-status"})
public class UpdateStatusServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        TaiKhoan acc = (TaiKhoan) session.getAttribute("acc");

        if (acc == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        try {
            int suCoId = Integer.parseInt(request.getParameter("suCoId"));
            String trangThaiMoi = request.getParameter("trangThaiMoi");

            SuCoDAO dao = new SuCoDAO();
            // Gọi hàm update trạng thái
            dao.updateTrangThaiSuCo(suCoId, trangThaiMoi);

        } catch (Exception e) {
            e.printStackTrace();
        }

        // Chuyển hướng về trang chủ nhân viên để load lại danh sách mới
        response.sendRedirect(request.getContextPath() + "/employee-home");
    }
}