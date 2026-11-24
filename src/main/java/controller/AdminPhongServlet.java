package controller;

import dao.PhongDAO;
import dao.SuCoDAO;
import model.Phong;
import model.TaiKhoan;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.net.URLEncoder;
import java.util.List;

@WebServlet(name = "AdminPhongServlet", urlPatterns = {"/admin-phong"})
public class AdminPhongServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        TaiKhoan acc = (TaiKhoan) session.getAttribute("acc");

        if (acc == null || !"ADMIN".equals(acc.getVaiTro())) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String building = request.getParameter("building");
        if (building == null || building.isEmpty() || "all".equalsIgnoreCase(building)) {
            building = "all";
        }

        String keyword = searchKeyword(request);
        PhongDAO phongDao = new PhongDAO();
        int offset = AdminPage.offset(request, phongDao.countRooms(building, keyword));
        List<Phong> listPhong = phongDao.getRoomsByBuilding(building, keyword, AdminPage.SIZE, offset);
        List<String> listToaNha = phongDao.getAllToaNha();

        SuCoDAO scDao = new SuCoDAO();
        int pending = scDao.countAdminIncidents("pending", "", "");

        request.setAttribute("listPhong", listPhong);
        request.setAttribute("listToaNha", listToaNha);
        request.setAttribute("currentBuilding", building);
        request.setAttribute("keyword", keyword);
        request.setAttribute("pending", pending);

        request.getRequestDispatcher("/admin/admin_phong.jsp").forward(request, response);
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
        String building = request.getParameter("building");
        if (building == null || building.isEmpty() || "all".equalsIgnoreCase(building)) {
            building = "all";
        }

        PhongDAO phongDao = new PhongDAO();
        boolean ok = false;
        String msg = "";
        String msgType = "success";

        try {
            if ("add".equals(action)) {
                String maPhong = request.getParameter("maPhong");
                String toaNha = request.getParameter("toaNha");
                int tang = Integer.parseInt(request.getParameter("tang"));
                String loaiPhong = request.getParameter("loaiPhong");
                String trangThai = request.getParameter("trangThai");

                ok = phongDao.addPhong(maPhong, toaNha, tang, loaiPhong, trangThai);
                msg = ok ? "Thêm phòng thành công!" : "Không thể thêm phòng (có thể bị trùng mã phòng trong cùng tòa).";
                msgType = ok ? "success" : "danger";
            } else if ("edit".equals(action)) {
                int phongId = Integer.parseInt(request.getParameter("phongId"));
                String maPhong = request.getParameter("maPhong");
                String toaNha = request.getParameter("toaNha");
                int tang = Integer.parseInt(request.getParameter("tang"));
                String loaiPhong = request.getParameter("loaiPhong");
                String trangThai = request.getParameter("trangThai");

                ok = phongDao.updatePhong(phongId, maPhong, toaNha, tang, loaiPhong, trangThai);
                msg = ok ? "Cập nhật thông tin phòng thành công!" : "Cập nhật phòng thất bại (kiểm tra lại mã phòng trùng).";
                msgType = ok ? "success" : "danger";
            } else if ("delete".equals(action)) {
                int phongId = Integer.parseInt(request.getParameter("phongId"));
                ok = phongDao.deletePhong(phongId);
                msg = ok ? "Đã xóa phòng thành công!" : "Không thể xóa phòng vì đang có sinh viên ở hoặc có dữ liệu sự cố liên quan.";
                msgType = ok ? "success" : "warning";
            }
        } catch (Exception e) {
            e.printStackTrace();
            msg = "Dữ liệu nhập vào không hợp lệ!";
            msgType = "danger";
        }

        session.setAttribute("phongMsg", msg);
        session.setAttribute("phongMsgType", msgType);
        response.sendRedirect(request.getContextPath() + "/admin-phong?building=" + URLEncoder.encode(building, "UTF-8")
                + "&q=" + URLEncoder.encode(searchKeyword(request), "UTF-8")
                + "&page=" + AdminPage.requestedPage(request));
    }

    private String searchKeyword(HttpServletRequest request) {
        String keyword = FormValidation.trim(request.getParameter("q"));
        return keyword.substring(0, Math.min(keyword.length(), 100));
    }
}