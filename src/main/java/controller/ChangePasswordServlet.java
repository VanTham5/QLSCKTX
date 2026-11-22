package controller;

import dao.TaiKhoanDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.TaiKhoan;
import java.io.IOException;

@WebServlet(name = "ChangePasswordServlet", urlPatterns = {"/change-password"})
public class ChangePasswordServlet extends HttpServlet {

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

        String oldPass = request.getParameter("oldPass");
        String newPass = request.getParameter("newPass");

        if ("NHAN_VIEN".equals(acc.getVaiTro())) {
            String page = "history".equals(request.getParameter("profilePage"))
                    ? "/employee-history" : "/employee-home";
            String result;
            if (oldPass == null || oldPass.isEmpty() || newPass == null || newPass.trim().isEmpty()
                    || !newPass.equals(request.getParameter("confirmPass"))) {
                result = "invalid";
            } else {
                result = new TaiKhoanDAO().changePassword(acc.getTaiKhoanId(), oldPass, newPass)
                        ? "success" : "failed";
            }
            response.sendRedirect(request.getContextPath() + page + "?passwordUpdate=" + result);
            return;
        }

        TaiKhoanDAO dao = new TaiKhoanDAO();
        boolean success = dao.changePassword(acc.getTaiKhoanId(), oldPass, newPass);

        // Lấy đường dẫn trang hiện tại để redirect ngược lại
        String referer = request.getHeader("referer");
        if (referer == null) referer = request.getContextPath() + "/student-home";

        if (success) {
            // Đổi thành công -> Chuyển hướng kèm param thông báo thành công
            response.sendRedirect(referer.split("\\?")[0] + "?msg=pass_success");
        } else {
            // Sai mật khẩu cũ -> Điều hướng kèm param lỗi để hiện khung báo đỏ
            response.sendRedirect(referer.split("\\?")[0] + "?error=wrong_old_pass");
        }
    }
}
//okokokokokok