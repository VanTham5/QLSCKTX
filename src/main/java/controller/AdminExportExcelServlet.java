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

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;

/**
 * Servlet xuất báo cáo sự cố và thống kê ra file Excel (.xlsx) cho Admin.
 * Tạo trực tiếp chuẩn OpenXML (.xlsx) bằng thư viện chuẩn JDK, không phụ thuộc thư viện ngoài.
 */
@WebServlet(name = "AdminExportExcelServlet", urlPatterns = {"/admin-export-excel"})
public class AdminExportExcelServlet extends HttpServlet {

    private static final int STYLE_DEFAULT = 0;
    private static final int STYLE_TITLE = 1;
    private static final int STYLE_SUBTITLE = 2;
    private static final int STYLE_HEADER = 3;
    private static final int STYLE_DATA = 4;
    private static final int STYLE_DATA_CENTER = 5;

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

        String fileName = "Bao_cao_su_co_KTX_" + fileDateFmt.format(new Date()) + ".xlsx";
        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        response.setHeader("Content-Disposition", "attachment; filename=\"" + fileName + "\"");

        try (ZipOutputStream zos = new ZipOutputStream(response.getOutputStream(), StandardCharsets.UTF_8)) {
            writeZipEntry(zos, "[Content_Types].xml", buildContentTypesXml());
            writeZipEntry(zos, "_rels/.rels", buildRootRelsXml());
            writeZipEntry(zos, "xl/workbook.xml", buildWorkbookXml());
            writeZipEntry(zos, "xl/_rels/workbook.xml.rels", buildWorkbookRelsXml());
            writeZipEntry(zos, "xl/styles.xml", buildStylesXml());
            writeZipEntry(zos, "xl/worksheets/sheet1.xml", buildIncidentSheetXml(listSuCo, dateFmt));
            writeZipEntry(zos, "xl/worksheets/sheet2.xml",
                    buildSummarySheetXml(total, pending, processing, done, totalStudents, byCategory));
            zos.finish();
        }
    }

    private void writeZipEntry(ZipOutputStream zos, String name, String content) throws IOException {
        zos.putNextEntry(new ZipEntry(name));
        zos.write(content.getBytes(StandardCharsets.UTF_8));
        zos.closeEntry();
    }

    private String buildContentTypesXml() {
        return "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>"
                + "<Types xmlns=\"http://schemas.openxmlformats.org/package/2006/content-types\">"
                + "<Default Extension=\"rels\" ContentType=\"application/vnd.openxmlformats-package.relationships+xml\"/>"
                + "<Default Extension=\"xml\" ContentType=\"application/xml\"/>"
                + "<Override PartName=\"/xl/workbook.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml\"/>"
                + "<Override PartName=\"/xl/worksheets/sheet1.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml\"/>"
                + "<Override PartName=\"/xl/worksheets/sheet2.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml\"/>"
                + "<Override PartName=\"/xl/styles.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.spreadsheetml.styles+xml\"/>"
                + "</Types>";
    }

    private String buildRootRelsXml() {
        return "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>"
                + "<Relationships xmlns=\"http://schemas.openxmlformats.org/package/2006/relationships\">"
                + "<Relationship Id=\"rId1\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument\" Target=\"xl/workbook.xml\"/>"
                + "</Relationships>";
    }

    private String buildWorkbookXml() {
        return "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>"
                + "<workbook xmlns=\"http://schemas.openxmlformats.org/spreadsheetml/2006/main\" "
                + "xmlns:r=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships\">"
                + "<sheets>"
                + "<sheet name=\"Danh sách sự cố\" sheetId=\"1\" r:id=\"rId1\"/>"
                + "<sheet name=\"Thống kê tổng quan\" sheetId=\"2\" r:id=\"rId2\"/>"
                + "</sheets>"
                + "</workbook>";
    }

    private String buildWorkbookRelsXml() {
        return "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>"
                + "<Relationships xmlns=\"http://schemas.openxmlformats.org/package/2006/relationships\">"
                + "<Relationship Id=\"rId1\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet\" Target=\"worksheets/sheet1.xml\"/>"
                + "<Relationship Id=\"rId2\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet\" Target=\"worksheets/sheet2.xml\"/>"
                + "<Relationship Id=\"rId3\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles\" Target=\"styles.xml\"/>"
                + "</Relationships>";
    }

    private String buildStylesXml() {
        return "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>"
                + "<styleSheet xmlns=\"http://schemas.openxmlformats.org/spreadsheetml/2006/main\">"
                + "<fonts count=\"4\">"
                + "<font><sz val=\"11\"/><name val=\"Calibri\"/></font>"
                + "<font><b/><sz val=\"14\"/><color rgb=\"FF1E3C72\"/><name val=\"Calibri\"/></font>"
                + "<font><i/><sz val=\"10\"/><color rgb=\"FF6B7280\"/><name val=\"Calibri\"/></font>"
                + "<font><b/><sz val=\"11\"/><color rgb=\"FFFFFFFF\"/><name val=\"Calibri\"/></font>"
                + "</fonts>"
                + "<fills count=\"3\">"
                + "<fill><patternFill patternType=\"none\"/></fill>"
                + "<fill><patternFill patternType=\"gray125\"/></fill>"
                + "<fill><patternFill patternType=\"solid\"><fgColor rgb=\"FF1E3C72\"/></patternFill></fill>"
                + "</fills>"
                + "<borders count=\"2\">"
                + "<border><left/><right/><top/><bottom/><diagonal/></border>"
                + "<border>"
                + "<left style=\"thin\"><color rgb=\"FFD1D5DB\"/></left>"
                + "<right style=\"thin\"><color rgb=\"FFD1D5DB\"/></right>"
                + "<top style=\"thin\"><color rgb=\"FFD1D5DB\"/></top>"
                + "<bottom style=\"thin\"><color rgb=\"FFD1D5DB\"/></bottom>"
                + "<diagonal/>"
                + "</border>"
                + "</borders>"
                + "<cellStyleXfs count=\"1\"><xf numFmtId=\"0\" fontId=\"0\" fillId=\"0\" borderId=\"0\"/></cellStyleXfs>"
                + "<cellXfs count=\"6\">"
                + "<xf numFmtId=\"0\" fontId=\"0\" fillId=\"0\" borderId=\"0\" xfId=\"0\"/>"
                + "<xf numFmtId=\"0\" fontId=\"1\" fillId=\"0\" borderId=\"0\" xfId=\"0\" applyFont=\"1\" applyAlignment=\"1\"><alignment horizontal=\"center\" vertical=\"center\"/></xf>"
                + "<xf numFmtId=\"0\" fontId=\"2\" fillId=\"0\" borderId=\"0\" xfId=\"0\" applyFont=\"1\" applyAlignment=\"1\"><alignment horizontal=\"center\" vertical=\"center\"/></xf>"
                + "<xf numFmtId=\"0\" fontId=\"3\" fillId=\"2\" borderId=\"1\" xfId=\"0\" applyFont=\"1\" applyFill=\"1\" applyBorder=\"1\" applyAlignment=\"1\"><alignment horizontal=\"center\" vertical=\"center\" wrapText=\"1\"/></xf>"
                + "<xf numFmtId=\"0\" fontId=\"0\" fillId=\"0\" borderId=\"1\" xfId=\"0\" applyBorder=\"1\" applyAlignment=\"1\"><alignment horizontal=\"left\" vertical=\"center\" wrapText=\"1\"/></xf>"
                + "<xf numFmtId=\"0\" fontId=\"0\" fillId=\"0\" borderId=\"1\" xfId=\"0\" applyBorder=\"1\" applyAlignment=\"1\"><alignment horizontal=\"center\" vertical=\"center\" wrapText=\"1\"/></xf>"
                + "</cellXfs>"
                + "</styleSheet>";
    }

    private String buildIncidentSheetXml(List<SuCo> listSuCo, SimpleDateFormat dateFmt) {
        StringBuilder sb = new StringBuilder();
        sb.append("<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>");
        sb.append("<worksheet xmlns=\"http://schemas.openxmlformats.org/spreadsheetml/2006/main\">");

        int[] widths = {6, 10, 28, 36, 22, 15, 22, 14, 16, 18, 22, 32};
        sb.append("<cols>");
        for (int i = 0; i < widths.length; i++) {
            int col = i + 1;
            sb.append("<col min=\"").append(col).append("\" max=\"").append(col)
                    .append("\" width=\"").append(widths[i]).append("\" customWidth=\"1\"/>");
        }
        sb.append("</cols>");

        sb.append("<sheetData>");
        sb.append("<row r=\"1\" ht=\"28\" customHeight=\"1\">");
        appendCell(sb, 0, 1, "BÁO CÁO TỔNG HỢP SỰ CỐ KÝ TÚC XÁ", STYLE_TITLE);
        sb.append("</row>");

        sb.append("<row r=\"2\" ht=\"20\" customHeight=\"1\">");
        appendCell(sb, 0, 2, "Ngày xuất báo cáo: " + dateFmt.format(new Date()), STYLE_SUBTITLE);
        sb.append("</row>");

        String[] headers = {
                "STT", "Mã SC", "Tiêu đề sự cố", "Mô tả chi tiết",
                "Người báo cáo", "SĐT Sinh viên", "Vị trí", "Mức độ",
                "Trạng thái", "Ngày gửi", "Nhân viên xử lý", "Ghi chú kỹ thuật"
        };
        sb.append("<row r=\"4\" ht=\"24\" customHeight=\"1\">");
        for (int i = 0; i < headers.length; i++) {
            appendCell(sb, i, 4, headers[i], STYLE_HEADER);
        }
        sb.append("</row>");

        int rowNum = 5;
        int stt = 1;
        for (SuCo sc : listSuCo) {
            sb.append("<row r=\"").append(rowNum).append("\">");
            appendCell(sb, 0, rowNum, String.valueOf(stt++), STYLE_DATA_CENTER);
            appendCell(sb, 1, rowNum, "#SC0" + sc.getSuCoId(), STYLE_DATA_CENTER);
            appendCell(sb, 2, rowNum, safe(sc.getTieuDe()), STYLE_DATA);
            appendCell(sb, 3, rowNum, safe(sc.getMoTa()), STYLE_DATA);
            appendCell(sb, 4, rowNum, safe(sc.getTenNguoiGui()), STYLE_DATA);
            appendCell(sb, 5, rowNum, safe(sc.getSoDienThoai()), STYLE_DATA_CENTER);
            appendCell(sb, 6, rowNum, safe(sc.getViTriPhong()), STYLE_DATA);
            appendCell(sb, 7, rowNum, safe(sc.getMucDo()), STYLE_DATA_CENTER);
            appendCell(sb, 8, rowNum, safe(sc.getTrangThai()), STYLE_DATA_CENTER);
            appendCell(sb, 9, rowNum, sc.getNgayGui() != null ? dateFmt.format(sc.getNgayGui()) : "", STYLE_DATA_CENTER);
            appendCell(sb, 10, rowNum, sc.getTenNhanVien() != null ? sc.getTenNhanVien() : "Chưa phân công", STYLE_DATA);
            appendCell(sb, 11, rowNum, safe(sc.getGhiChuKyThuat()), STYLE_DATA);
            sb.append("</row>");
            rowNum++;
        }
        sb.append("</sheetData>");

        sb.append("<mergeCells count=\"2\">");
        sb.append("<mergeCell ref=\"A1:L1\"/>");
        sb.append("<mergeCell ref=\"A2:L2\"/>");
        sb.append("</mergeCells>");
        sb.append("</worksheet>");
        return sb.toString();
    }

    private String buildSummarySheetXml(int total, int pending, int processing, int done,
                                        int totalStudents, Map<String, Integer> byCategory) {
        StringBuilder sb = new StringBuilder();
        sb.append("<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>");
        sb.append("<worksheet xmlns=\"http://schemas.openxmlformats.org/spreadsheetml/2006/main\">");
        sb.append("<cols>");
        sb.append("<col min=\"1\" max=\"1\" width=\"34\" customWidth=\"1\"/>");
        sb.append("<col min=\"2\" max=\"2\" width=\"20\" customWidth=\"1\"/>");
        sb.append("</cols>");

        sb.append("<sheetData>");
        sb.append("<row r=\"1\" ht=\"28\" customHeight=\"1\">");
        appendCell(sb, 0, 1, "THỐNG KÊ TÌNH HÌNH HOẠT ĐỘNG KÝ TÚC XÁ", STYLE_TITLE);
        sb.append("</row>");

        sb.append("<row r=\"3\" ht=\"22\" customHeight=\"1\">");
        appendCell(sb, 0, 3, "Chỉ tiêu thống kê", STYLE_HEADER);
        appendCell(sb, 1, 3, "Số lượng", STYLE_HEADER);
        sb.append("</row>");

        String[][] metrics = {
                {"Tổng số sự cố", String.valueOf(total)},
                {"Chờ phân công xử lý", String.valueOf(pending)},
                {"Đang tiến hành sửa chữa", String.valueOf(processing)},
                {"Đã hoàn thành", String.valueOf(done)},
                {"Tổng sinh viên nội trú", String.valueOf(totalStudents)}
        };
        int r = 4;
        for (String[] m : metrics) {
            sb.append("<row r=\"").append(r).append("\">");
            appendCell(sb, 0, r, m[0], STYLE_DATA);
            appendCell(sb, 1, r, m[1], STYLE_DATA_CENTER);
            sb.append("</row>");
            r++;
        }

        r++;
        sb.append("<row r=\"").append(r).append("\" ht=\"22\" customHeight=\"1\">");
        appendCell(sb, 0, r, "Loại sự cố", STYLE_HEADER);
        appendCell(sb, 1, r, "Số lượng báo cáo", STYLE_HEADER);
        sb.append("</row>");
        r++;

        if (byCategory != null) {
            for (Map.Entry<String, Integer> entry : byCategory.entrySet()) {
                sb.append("<row r=\"").append(r).append("\">");
                appendCell(sb, 0, r, safe(entry.getKey()), STYLE_DATA);
                appendCell(sb, 1, r, String.valueOf(entry.getValue()), STYLE_DATA_CENTER);
                sb.append("</row>");
                r++;
            }
        }
        sb.append("</sheetData>");

        sb.append("<mergeCells count=\"1\">");
        sb.append("<mergeCell ref=\"A1:B1\"/>");
        sb.append("</mergeCells>");
        sb.append("</worksheet>");
        return sb.toString();
    }

    private void appendCell(StringBuilder sb, int colIdx, int rowNum, String value, int styleIdx) {
        String ref = colName(colIdx) + rowNum;
        sb.append("<c r=\"").append(ref).append("\" s=\"").append(styleIdx).append("\" t=\"inlineStr\">")
                .append("<is><t>").append(escapeXml(value)).append("</t></is></c>");
    }

    private String colName(int index) {
        StringBuilder name = new StringBuilder();
        int n = index;
        while (n >= 0) {
            name.insert(0, (char) ('A' + (n % 26)));
            n = (n / 26) - 1;
        }
        return name.toString();
    }

    private String safe(String val) {
        return val != null ? val : "";
    }

    private String escapeXml(String input) {
        if (input == null) {
            return "";
        }
        StringBuilder out = new StringBuilder(input.length());
        for (int i = 0; i < input.length(); i++) {
            char c = input.charAt(i);
            if (c < 0x20 && c != '\t' && c != '\n' && c != '\r') {
                continue;
            }
            switch (c) {
                case '&': out.append("&amp;"); break;
                case '<': out.append("&lt;"); break;
                case '>': out.append("&gt;"); break;
                case '"': out.append("&quot;"); break;
                case '\'': out.append("&apos;"); break;
                default: out.append(c);
            }
        }
        return out.toString();
    }
}
