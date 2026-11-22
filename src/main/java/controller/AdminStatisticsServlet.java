package controller;

import dao.SuCoDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.List;
import java.util.Map;
import model.SuCo;
import model.TaiKhoan;

@WebServlet(name = "AdminStatisticsServlet", urlPatterns = {"/admin-statistics"})
public class AdminStatisticsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        TaiKhoan acc = (session != null) ? (TaiKhoan) session.getAttribute("acc") : null;
        if (acc == null || !"ADMIN".equals(acc.getVaiTro())) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String range = request.getParameter("range");
        String fromDateParam = request.getParameter("fromDate");
        String toDateParam = request.getParameter("toDate");

        if (range == null || range.trim().isEmpty()) {
            range = "this_month";
        }

        LocalDate today = LocalDate.now();
        LocalDate startDate;
        LocalDate endExclusive;
        LocalDate prevStartDate;
        LocalDate prevEndExclusive;
        String rangeLabel;

        switch (range) {
            case "last_month": {
                LocalDate firstLastMonth = today.minusMonths(1).withDayOfMonth(1);
                startDate = firstLastMonth;
                endExclusive = today.withDayOfMonth(1);
                prevStartDate = firstLastMonth.minusMonths(1);
                prevEndExclusive = firstLastMonth;
                rangeLabel = "Tháng trước";
                break;
            }
            case "last_6_months": {
                startDate = today.minusMonths(5).withDayOfMonth(1);
                endExclusive = today.plusDays(1);
                prevStartDate = startDate.minusMonths(6);
                prevEndExclusive = startDate;
                rangeLabel = "6 tháng qua";
                break;
            }
            case "this_year": {
                startDate = today.withDayOfYear(1);
                endExclusive = today.plusDays(1);
                prevStartDate = startDate.minusYears(1);
                prevEndExclusive = startDate;
                rangeLabel = "Năm nay";
                break;
            }
            case "custom": {
                LocalDate parsedFrom = parseDateOrDefault(fromDateParam, today.withDayOfMonth(1));
                LocalDate parsedTo = parseDateOrDefault(toDateParam, today);
                if (parsedFrom.isAfter(parsedTo)) {
                    LocalDate tmp = parsedFrom;
                    parsedFrom = parsedTo;
                    parsedTo = tmp;
                }
                startDate = parsedFrom;
                endExclusive = parsedTo.plusDays(1);
                long days = Math.max(1, ChronoUnit.DAYS.between(startDate, endExclusive));
                prevStartDate = startDate.minusDays(days);
                prevEndExclusive = startDate;
                rangeLabel = "Từ " + parsedFrom + " đến " + parsedTo;
                fromDateParam = parsedFrom.toString();
                toDateParam = parsedTo.toString();
                break;
            }
            case "this_month":
            default: {
                range = "this_month";
                startDate = today.withDayOfMonth(1);
                endExclusive = today.plusDays(1);
                prevStartDate = startDate.minusMonths(1);
                prevEndExclusive = startDate;
                rangeLabel = "Tháng này";
                break;
            }
        }

        Timestamp fromTs = Timestamp.valueOf(startDate.atStartOfDay());
        Timestamp toTs = Timestamp.valueOf(endExclusive.atStartOfDay());
        Timestamp prevFromTs = Timestamp.valueOf(prevStartDate.atStartOfDay());
        Timestamp prevToTs = Timestamp.valueOf(prevEndExclusive.atStartOfDay());

        SuCoDAO suCoDAO = new SuCoDAO();

        // Dữ liệu kỳ hiện tại
        Map<String, Integer> byLoai = suCoDAO.getCountByLoaiSuCo(fromTs, toTs);
        Map<String, Integer> byTrangThai = suCoDAO.getCountByTrangThai(fromTs, toTs);
        List<SuCo> recentList = suCoDAO.getRecentSuCoForAdmin(fromTs, toTs, 6);

        int completedCount = byTrangThai.getOrDefault("Hoàn thành", 0);
        int processingCount = byTrangThai.getOrDefault("Đang xử lý", 0);
        int pendingCount = byTrangThai.getOrDefault("Chờ xử lý", 0);
        int totalSuCo = byTrangThai.values().stream().mapToInt(Integer::intValue).sum();

        // Dữ liệu kỳ trước để tính % tăng/giảm
        Map<String, Integer> prevTrangThai = suCoDAO.getCountByTrangThai(prevFromTs, prevToTs);
        int prevCompleted = prevTrangThai.getOrDefault("Hoàn thành", 0);
        int prevProcessing = prevTrangThai.getOrDefault("Đang xử lý", 0);
        int prevPending = prevTrangThai.getOrDefault("Chờ xử lý", 0);
        int prevTotal = prevTrangThai.values().stream().mapToInt(Integer::intValue).sum();

        int totalChange = calcPercentChange(totalSuCo, prevTotal);
        int completedChange = calcPercentChange(completedCount, prevCompleted);
        int processingChange = calcPercentChange(processingCount, prevProcessing);
        int pendingChange = calcPercentChange(pendingCount, prevPending);

        // Loại sự cố nhiều nhất
        String topLoai = "Chưa có dữ liệu";
        int maxLoaiCount = 0;
        for (Map.Entry<String, Integer> entry : byLoai.entrySet()) {
            if (entry.getValue() > maxLoaiCount) {
                maxLoaiCount = entry.getValue();
                topLoai = entry.getKey();
            }
        }
        int completionRate = (totalSuCo > 0) ? Math.round((completedCount * 100f) / totalSuCo) : 0;

        request.setAttribute("range", range);
        request.setAttribute("rangeLabel", rangeLabel);
        request.setAttribute("fromDate", fromDateParam != null ? fromDateParam : startDate.toString());
        request.setAttribute("toDate", toDateParam != null ? toDateParam : endExclusive.minusDays(1).toString());

        request.setAttribute("totalSuCo", totalSuCo);
        request.setAttribute("completedCount", completedCount);
        request.setAttribute("processingCount", processingCount);
        request.setAttribute("pendingCount", pendingCount);
        request.setAttribute("pending", pendingCount);

        request.setAttribute("totalChange", totalChange);
        request.setAttribute("completedChange", completedChange);
        request.setAttribute("processingChange", processingChange);
        request.setAttribute("pendingChange", pendingChange);

        request.setAttribute("topLoai", topLoai);
        request.setAttribute("maxLoaiCount", maxLoaiCount);
        request.setAttribute("completionRate", completionRate);
        request.setAttribute("recentList", recentList);

        request.setAttribute("loaiLabelsJson", toJsonStringArray(byLoai.keySet().toArray(new String[0])));
        request.setAttribute("loaiValuesJson", toJsonIntArray(byLoai.values().toArray(new Integer[0])));
        request.setAttribute("trangThaiLabelsJson", toJsonStringArray(byTrangThai.keySet().toArray(new String[0])));
        request.setAttribute("trangThaiValuesJson", toJsonIntArray(byTrangThai.values().toArray(new Integer[0])));

        request.getRequestDispatcher("/admin/admin_statistics.jsp").forward(request, response);
    }

    private LocalDate parseDateOrDefault(String value, LocalDate fallback) {
        if (value == null || value.trim().isEmpty()) return fallback;
        try {
            return LocalDate.parse(value.trim());
        } catch (Exception e) {
            return fallback;
        }
    }

    private int calcPercentChange(int current, int previous) {
        if (previous == 0) {
            return current > 0 ? 100 : 0;
        }
        return Math.round(((current - previous) * 100f) / previous);
    }

    private String toJsonStringArray(String[] items) {
        StringBuilder sb = new StringBuilder("[");
        for (int i = 0; i < items.length; i++) {
            if (i > 0) sb.append(",");
            sb.append("\"").append(escapeJson(items[i])).append("\"");
        }
        sb.append("]");
        return sb.toString();
    }

    private String toJsonIntArray(Integer[] items) {
        StringBuilder sb = new StringBuilder("[");
        for (int i = 0; i < items.length; i++) {
            if (i > 0) sb.append(",");
            sb.append(items[i] != null ? items[i] : 0);
        }
        sb.append("]");
        return sb.toString();
    }

    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("'", "\\u0027")
                .replace("\n", "\\n")
                .replace("\r", "\\r");
    }
}