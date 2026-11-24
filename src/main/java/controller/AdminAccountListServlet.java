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

        if ("create".equals(action)) {
            String hoTen = request.getParameter("hoTen");
            String tenDangNhap = request.getParameter("tenDangNhap");
            String matKhau = request.getParameter("matKhau");
            String vaiTro = request.getParameter("vaiTro");
            String toIdStr = request.getParameter("toId");

            Integer toId = (toIdStr != null && !toIdStr.trim().isEmpty()) ? Integer.parseInt(toIdStr) : null;

            TaiKhoanDAO dao = new TaiKhoanDAO();
            if (dao.checkExistUsername(tenDangNhap)) {
                session.setAttribute("accountMsgType", "danger");
                session.setAttribute("accountMsg", "Tên đăng nhập \"" + tenDangNhap + "\" đã tồn tại trong hệ thống!");
            } else {
                boolean created = dao.createAccountByAdmin(hoTen, tenDangNhap, matKhau, vaiTro, toId);
                if (created) {
                    session.setAttribute("accountMsgType", "success");
                    session.setAttribute("accountMsg", "Cấp tài khoản \"" + tenDangNhap + "\" thành công!");
                } else {
                    session.setAttribute("accountMsgType", "danger");
                    session.setAttribute("accountMsg", "Không thể tạo tài khoản. Vui lòng thử lại!");
                }
            }

            response.sendRedirect(request.getContextPath() + "/admin-accounts");
            return;
        }


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