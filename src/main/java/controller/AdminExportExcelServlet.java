package controller;

import dao.SuCoDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.SuCo;
import model.TaiKhoan;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.ss.util.CellRangeAddress;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.Map;

/**
 * Servlet xuất báo cáo sự cố và thống kê ra file Excel (.xlsx) cho Admin.
 */
@WebServlet(name = "AdminExportExcelServlet", urlPatterns = {"/admin-export-excel"})
public class AdminExportExcelServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        TaiKhoan acc = (session != null) ? (TaiKhoan) session.getAttribute("acc") : null;
        if (acc == null || !"ADMIN".equalsIgnoreCase(acc.getVaiTro())) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        SuCoDAO dao = new SuCoDAO();
        List<SuCo> listSuCo = dao.getAllSuCoForAdmin("all");
        int total = dao.countAdminIncidents("all", "", "");
        int pending = dao.countAdminIncidents("pending", "", "");
        int processing = dao.countAdminIncidents("processing", "", "");
        int done = dao.countAdminIncidents("done", "", "");
        int totalStudents = dao.countTotalStudents();
        Map<String, Integer> byCategory = dao.getCountByLoaiSuCo();

        SimpleDateFormat dateFmt = new SimpleDateFormat("dd/MM/yyyy HH:mm");
        SimpleDateFormat fileDateFmt = new SimpleDateFormat("yyyyMMdd_HHmm");

        try (Workbook workbook = new XSSFWorkbook()) {
            CellStyle titleStyle = createTitleStyle(workbook);
            CellStyle subtitleStyle = createSubtitleStyle(workbook);
            CellStyle headerStyle = createHeaderStyle(workbook);
            CellStyle dataStyle = createDataStyle(workbook, false);
            CellStyle centerStyle = createDataStyle(workbook, true);

            buildIncidentSheet(workbook, listSuCo, dateFmt, titleStyle, subtitleStyle, headerStyle, dataStyle, centerStyle);
            buildSummarySheet(workbook, total, pending, processing, done, totalStudents, byCategory,
                    titleStyle, headerStyle, dataStyle, centerStyle);

            String fileName = "Bao_cao_su_co_KTX_" + fileDateFmt.format(new Date()) + ".xlsx";
            response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
            response.setHeader("Content-Disposition", "attachment; filename=\"" + fileName + "\"");
            workbook.write(response.getOutputStream());
            response.getOutputStream().flush();
        }
    }

    private void buildIncidentSheet(Workbook workbook, List<SuCo> listSuCo, SimpleDateFormat dateFmt,
                                    CellStyle titleStyle, CellStyle subtitleStyle, CellStyle headerStyle,
                                    CellStyle dataStyle, CellStyle centerStyle) {
        Sheet sheet = workbook.createSheet("Danh sách sự cố");

        Row titleRow = sheet.createRow(0);
        titleRow.setHeightInPoints(28);
        Cell titleCell = titleRow.createCell(0);
        titleCell.setCellValue("BÁO CÁO TỔNG HỢP SỰ CỐ KÝ TÚC XÁ");
        titleCell.setCellStyle(titleStyle);
        sheet.addMergedRegion(new CellRangeAddress(0, 0, 0, 11));

        Row subRow = sheet.createRow(1);
        Cell subCell = subRow.createCell(0);
        subCell.setCellValue("Ngày xuất báo cáo: " + dateFmt.format(new Date()));
        subCell.setCellStyle(subtitleStyle);
        sheet.addMergedRegion(new CellRangeAddress(1, 1, 0, 11));

        String[] headers = {
                "STT", "Mã SC", "Tiêu đề sự cố", "Mô tả chi tiết",
                "Người báo cáo", "SĐT Sinh viên", "Vị trí", "Mức độ",
                "Trạng thái", "Ngày gửi", "Nhân viên xử lý", "Ghi chú kỹ thuật"
        };
        Row headerRow = sheet.createRow(3);
        headerRow.setHeightInPoints(24);
        for (int i = 0; i < headers.length; i++) {
            Cell cell = headerRow.createCell(i);
            cell.setCellValue(headers[i]);
            cell.setCellStyle(headerStyle);
        }

        int rowIdx = 4;
        int stt = 1;
        for (SuCo sc : listSuCo) {
            Row row = sheet.createRow(rowIdx++);
            setCell(row, 0, String.valueOf(stt++), centerStyle);
            setCell(row, 1, "#SC0" + sc.getSuCoId(), centerStyle);
            setCell(row, 2, safe(sc.getTieuDe()), dataStyle);
            setCell(row, 3, safe(sc.getMoTa()), dataStyle);
            setCell(row, 4, safe(sc.getTenNguoiGui()), dataStyle);
            setCell(row, 5, safe(sc.getSoDienThoai()), centerStyle);
            setCell(row, 6, safe(sc.getViTriPhong()), dataStyle);
            setCell(row, 7, safe(sc.getMucDo()), centerStyle);
            setCell(row, 8, safe(sc.getTrangThai()), centerStyle);
            setCell(row, 9, sc.getNgayGui() != null ? dateFmt.format(sc.getNgayGui()) : "", centerStyle);
            setCell(row, 10, sc.getTenNhanVien() != null ? sc.getTenNhanVien() : "Chưa phân công", dataStyle);
            setCell(row, 11, safe(sc.getGhiChuKyThuat()), dataStyle);
        }

        int[] widths = {6, 10, 28, 36, 22, 15, 22, 14, 16, 18, 22, 32};
        for (int i = 0; i < widths.length; i++) {
            sheet.setColumnWidth(i, widths[i] * 256);
        }
    }

    private void buildSummarySheet(Workbook workbook, int total, int pending, int processing, int done,
                                   int totalStudents, Map<String, Integer> byCategory,
                                   CellStyle titleStyle, CellStyle headerStyle,
                                   CellStyle dataStyle, CellStyle centerStyle) {
        Sheet sheet = workbook.createSheet("Thống kê tổng quan");

        Row titleRow = sheet.createRow(0);
        titleRow.setHeightInPoints(28);
        Cell titleCell = titleRow.createCell(0);
        titleCell.setCellValue("THỐNG KÊ TÌNH HÌNH HOẠT ĐỘNG KÝ TÚC XÁ");
        titleCell.setCellStyle(titleStyle);
        sheet.addMergedRegion(new CellRangeAddress(0, 0, 0, 2));

        Row header1 = sheet.createRow(2);
        header1.setHeightInPoints(22);
        setCell(header1, 0, "Chỉ tiêu thống kê", headerStyle);
        setCell(header1, 1, "Số lượng", headerStyle);

        String[][] metrics = {
                {"Tổng số sự cố", String.valueOf(total)},
                {"Chờ phân công xử lý", String.valueOf(pending)},
                {"Đang tiến hành sửa chữa", String.valueOf(processing)},
                {"Đã hoàn thành", String.valueOf(done)},
                {"Tổng sinh viên nội trú", String.valueOf(totalStudents)}
        };
        int r = 3;
        for (String[] m : metrics) {
            Row row = sheet.createRow(r++);
            setCell(row, 0, m[0], dataStyle);
            setCell(row, 1, m[1], centerStyle);
        }

        r += 1;
        Row header2 = sheet.createRow(r++);
        header2.setHeightInPoints(22);
        setCell(header2, 0, "Loại sự cố", headerStyle);
        setCell(header2, 1, "Số lượng báo cáo", headerStyle);

        if (byCategory != null) {
            for (Map.Entry<String, Integer> entry : byCategory.entrySet()) {
                Row row = sheet.createRow(r++);
                setCell(row, 0, entry.getKey(), dataStyle);
                setCell(row, 1, String.valueOf(entry.getValue()), centerStyle);
            }
        }

        sheet.setColumnWidth(0, 34 * 256);
        sheet.setColumnWidth(1, 20 * 256);
    }

    private void setCell(Row row, int col, String value, CellStyle style) {
        Cell cell = row.createCell(col);
        cell.setCellValue(value);
        cell.setCellStyle(style);
    }

    private String safe(String val) {
        return val != null ? val : "";
    }

    private CellStyle createTitleStyle(Workbook wb) {
        CellStyle style = wb.createCellStyle();
        Font font = wb.createFont();
        font.setBold(true);
        font.setFontHeightInPoints((short) 14);
        font.setColor(IndexedColors.DARK_BLUE.getIndex());
        style.setFont(font);
        style.setAlignment(HorizontalAlignment.CENTER);
        style.setVerticalAlignment(VerticalAlignment.CENTER);
        return style;
    }

    private CellStyle createSubtitleStyle(Workbook wb) {
        CellStyle style = wb.createCellStyle();
        Font font = wb.createFont();
        font.setItalic(true);
        font.setFontHeightInPoints((short) 10);
        font.setColor(IndexedColors.GREY_50_PERCENT.getIndex());
        style.setFont(font);
        style.setAlignment(HorizontalAlignment.CENTER);
        return style;
    }

    private CellStyle createHeaderStyle(Workbook wb) {
        CellStyle style = wb.createCellStyle();
        Font font = wb.createFont();
        font.setBold(true);
        font.setFontHeightInPoints((short) 11);
        font.setColor(IndexedColors.WHITE.getIndex());
        style.setFont(font);
        style.setFillForegroundColor(IndexedColors.DARK_BLUE.getIndex());
        style.setFillPattern(FillPatternType.SOLID_FOREGROUND);
        style.setAlignment(HorizontalAlignment.CENTER);
        style.setVerticalAlignment(VerticalAlignment.CENTER);
        applyBorders(style);
        return style;
    }

    private CellStyle createDataStyle(Workbook wb, boolean center) {
        CellStyle style = wb.createCellStyle();
        style.setAlignment(center ? HorizontalAlignment.CENTER : HorizontalAlignment.LEFT);
        style.setVerticalAlignment(VerticalAlignment.CENTER);
        style.setWrapText(true);
        applyBorders(style);
        return style;
    }

    private void applyBorders(CellStyle style) {
        style.setBorderTop(BorderStyle.THIN);
        style.setBorderBottom(BorderStyle.THIN);
        style.setBorderLeft(BorderStyle.THIN);
        style.setBorderRight(BorderStyle.THIN);
    }
}
