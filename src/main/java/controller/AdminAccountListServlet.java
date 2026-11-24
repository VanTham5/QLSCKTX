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

@WebServlet(name = "AdminAccountListServlet", urlPatterns = {"/admin-accounts"})
public class AdminAccountListServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        if (!checkAdmin(request, response)) {
            return;
        }
        TaiKhoanDAO dao = new TaiKhoanDAO();
        if ("checkUsername".equals(request.getParameter("action"))) {
            String username = FormValidation.trim(request.getParameter("username"));
            if (!FormValidation.username(username)) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST);
                return;
            }
            response.setContentType("application/json;charset=UTF-8");
            response.setHeader("Cache-Control", "no-store");
            response.getWriter().print(dao.checkExistUsername(username));
            return;
        }

        String role = roleFilter(request.getParameter("role"));
        String team = FormValidation.trim(request.getParameter("team"));
        String status = FormValidation.trim(request.getParameter("status"));
        if (!"0".equals(status) && !"1".equals(status)) {
            status = "";
        }
        String keyword = FormValidation.trim(request.getParameter("q"));
        if (keyword.length() > 100) {
            keyword = keyword.substring(0, 100);
        }

        int total = dao.countAdminAccounts(role, team, status, keyword);
        int offset = AdminPage.offset(request, total);
        request.setAttribute("listAccounts", dao.getAdminAccounts(role, team, status, keyword, AdminPage.SIZE, offset));
        request.setAttribute("currentRole", role);
        request.setAttribute("teamFilter", team);
        request.setAttribute("statusFilter", status);
        request.setAttribute("keyword", keyword);
        request.setAttribute("pending", new SuCoDAO().countAdminIncidents("pending", "", ""));
        request.getRequestDispatcher("/admin/admin_account_list.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        request.setCharacterEncoding("UTF-8");
        if (!checkAdmin(request, response)) {
            return;
        }

        String action = request.getParameter("action");
        TaiKhoanDAO dao = new TaiKhoanDAO();
        if ("create".equals(action)) {
            createAccount(request, dao);
            response.sendRedirect(request.getContextPath() + "/admin-accounts");
            return;
        }
        if (!"updateStatus".equals(action)) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        int accountId = FormValidation.positiveId(request.getParameter("taiKhoanId"));
        String status = request.getParameter("trangThaiMoi");
        if (accountId == 0 || (!"0".equals(status) && !"1".equals(status))) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        boolean updated = dao.updateAccountStatus(accountId, Integer.parseInt(status));
        if ("fetch".equals(request.getHeader("X-Requested-With"))) {
            response.setStatus(updated ? HttpServletResponse.SC_NO_CONTENT : HttpServletResponse.SC_CONFLICT);
        } else {
            if (!updated) {
                request.getSession().setAttribute("accountMsgType", "danger");
                request.getSession().setAttribute("accountMsg", "Không thể cập nhật trạng thái tài khoản.");
            }
            String role = roleFilter(request.getParameter("role"));
            int page = Math.max(1, FormValidation.positiveId(request.getParameter("page")));
            response.sendRedirect(request.getContextPath() + "/admin-accounts?role=" + role + "&page=" + page);
        }
    }

    private void createAccount(HttpServletRequest request, TaiKhoanDAO dao) {
        String name = FormValidation.trim(request.getParameter("hoTen"));
        String username = FormValidation.trim(request.getParameter("tenDangNhap"));
        String password = request.getParameter("matKhau");
        String role = request.getParameter("vaiTro");
        boolean employee = "NHAN_VIEN".equals(role);
        int teamId = FormValidation.positiveId(request.getParameter("toId"));

        String message;
        boolean created = false;
        if (!FormValidation.text(name, 1, 100) || !FormValidation.username(username)
                || !FormValidation.password(password) || (!employee && !"SINH_VIEN".equals(role))) {
            message = "Kiểm tra họ tên, tên đăng nhập (3–50 ký tự hợp lệ), mật khẩu (ít nhất 6 ký tự) và vai trò.";
        } else if (employee && teamId == 0) {
            message = "Vui lòng chọn tổ phụ trách cho nhân viên.";
        } else if (dao.checkExistUsername(username)) {
            message = "Tên đăng nhập đã tồn tại trong hệ thống.";
        } else {
            created = dao.createAccountByAdmin(name, username, password, role, employee ? teamId : null);
            if (created) {
                message = "Cấp tài khoản thành công.";
            } else if (dao.checkExistUsername(username)) {
                message = "Tên đăng nhập đã tồn tại trong hệ thống.";
            } else {
                message = "Không thể tạo tài khoản. Kiểm tra tổ phụ trách hoặc thử lại.";
            }
        }
        HttpSession session = request.getSession();
        session.setAttribute("accountMsgType", created ? "success" : "danger");
        session.setAttribute("accountMsg", message);
    }

    private boolean checkAdmin(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        TaiKhoan account = session == null ? null : (TaiKhoan) session.getAttribute("acc");
        if (account == null || !"ADMIN".equals(account.getVaiTro())) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return false;
        }
        return true;
    }

    private String roleFilter(String role) {
        return "NHAN_VIEN".equals(role) || "SINH_VIEN".equals(role) ? role : "all";
    }
}
