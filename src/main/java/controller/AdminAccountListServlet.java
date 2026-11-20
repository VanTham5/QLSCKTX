package controller;

import dao.SuCoDAO;
import dao.TaiKhoanDAO;
import model.TaiKhoan;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "AdminAccountListServlet", urlPatterns = {"/admin-accounts"})
public class AdminAccountListServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        TaiKhoan acc = (TaiKhoan) session.getAttribute("acc");

        if (acc == null || !"ADMIN".equals(acc.getVaiTro())) {
            response.sendRedirect("login.jsp");
            return;
        }

        // Lấy tham số lọc vai trò (mặc định là 'all')
        String role = request.getParameter("role");
        if (role == null) {
            role = "all";
        }

        TaiKhoanDAO tkDao = new TaiKhoanDAO();
        List<TaiKhoan> listAccounts = tkDao.getAccountsByRole(role);

        // Đếm số lượng sự cố chờ xử lý để hiển thị badge đỏ trên sidebar menu
        SuCoDAO scDao = new SuCoDAO();
        int pending = scDao.getAllSuCoForAdmin("pending").size();

        request.setAttribute("listAccounts", listAccounts);
        request.setAttribute("currentRole", role);
        request.setAttribute("pending", pending);

        request.getRequestDispatcher("/admin/admin_account_list.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        TaiKhoan acc = (TaiKhoan) session.getAttribute("acc");

        if (acc == null || !"ADMIN".equals(acc.getVaiTro())) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String action = request.getParameter("action");
        if ("updateStatus".equals(action)) {
            try {
                int taiKhoanId = Integer.parseInt(request.getParameter("taiKhoanId"));
                int trangThaiMoi = Integer.parseInt(request.getParameter("trangThaiMoi")); // 1 hoặc 0

                TaiKhoanDAO tkDao = new TaiKhoanDAO();
                tkDao.updateAccountStatus(taiKhoanId, trangThaiMoi);
            } catch (NumberFormatException e) {
                e.printStackTrace();
            }
        }

        String role = request.getParameter("role");
        if (role == null || role.isEmpty()) {
            role = "all";
        }
        response.sendRedirect(request.getContextPath() + "/admin-accounts?role=" + role);
    }
}