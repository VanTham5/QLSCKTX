<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="model.SuCo" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Trang Quản Trị - KTX Support</title>
    <!-- Bootstrap 5 -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- FontAwesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/incident-pagination.css">
    <!-- Chart.js -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        body {
            background-color: #f4f6f9;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            overflow-x: hidden;
        }
        /* Sidebar */
        .sidebar {
            width: 260px;
            background-color: #343a40;
            height: 100vh;
            position: fixed;
            left: 0;
            top: 0;
            z-index: 1000;
        }
        .main-content {
            margin-left: 260px;
            min-height: 100vh;
            padding-bottom: 30px;
        }
        .sidebar .nav-link {
            color: #c2c7d0;
            padding: 12px 20px;
            font-weight: 500;
            border-left: 3px solid transparent;
        }
        .sidebar .nav-link:hover, .sidebar .nav-link.active {
            background-color: rgba(255,255,255,0.1);
            color: #ffffff;
            border-left: 3px solid #0d6efd;
        }
        .sidebar-heading {
            font-size: 0.75rem;
            text-transform: uppercase;
            color: #6c757d;
            font-weight: bold;
            padding: 10px 20px;
            margin-top: 15px;
        }
        .w-20px { width: 22px; text-align: center; }

        /* Top Header */
        .top-header {
            background-color: #ffffff;
            height: 60px;
            border-bottom: 1px solid #e0e0e0;
            display: flex;
            justify-content: flex-end;
            align-items: center;
            padding: 0 30px;
            position: sticky;
            top: 0;
            z-index: 999;
        }
        .stat-card {
            border: none;
            border-radius: 12px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.03);
            transition: transform 0.2s;
        }
        .stat-card:hover { transform: translateY(-3px); }
        .icon-box {
            width: 50px;
            height: 50px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.5rem;
        }
    </style>
</head>
<body>

<!-- SIDEBAR ADMIN -->
<div class="sidebar d-flex flex-column" style="overflow-y: auto;">
    <div class="d-flex align-items-center p-3 border-bottom border-secondary" style="height: 60px;">
        <i class="fa-solid fa-server fs-4 text-primary me-2"></i>
        <h5 class="mb-0 fw-bold text-white" style="font-size: 1.1rem;">QUẢN TRỊ HỆ THỐNG</h5>
    </div>

    <div class="sidebar-heading">Tổng quan</div>
    <a href="${pageContext.request.contextPath}/admin-home" class="nav-link"><i class="fa-solid fa-chart-line me-2 w-20px"></i> Bảng điều khiển</a>

    <div class="sidebar-heading">Nghiệp vụ</div>
    <a href="#" class="nav-link" data-bs-toggle="modal" data-bs-target="#createNoticeModal">
        <i class="fa-solid fa-bullhorn me-2 w-20px"></i> Đăng thông báo
    </a>
    <a href="${pageContext.request.contextPath}/admin-incidents" class="nav-link">
        <span><i class="fa-solid fa-triangle-exclamation me-2 w-20px"></i> Quản lý sự cố</span>
        <span class="badge bg-danger rounded-pill">${pending != null ? pending : 0}</span>
    </a>
    <a href="${pageContext.request.contextPath}/admin-accounts" class="nav-link">
        <i class="fa-solid fa-users me-2 w-20px"></i> Quản lý tài khoản
    </a>
    <a href="${pageContext.request.contextPath}/admin-phong" class="nav-link"><i class="fa-solid fa-building me-2 w-20px"></i> Quản lý phòng/tòa</a>    <a href="${pageContext.request.contextPath}/admin-loai-su-co" class="nav-link"><i class="fa-solid fa-list me-2 w-20px"></i> Danh mục loại sự cố</a>
    <a href="${pageContext.request.contextPath}/admin-statistics" class="nav-link"><i class="fa-solid fa-chart-pie me-2 w-20px"></i> Thống kê</a>

    <div class="sidebar-heading">Hệ thống</div>
    <a href="#" class="nav-link" data-bs-toggle="modal" data-bs-target="#adminProfileModal">
        <i class="fa-solid fa-user-gear me-2 w-20px"></i> Cấu hình tài khoản
    </a>
    <a href="${pageContext.request.contextPath}/logout" class="nav-link text-danger mt-3 mb-4"><i class="fa-solid fa-right-from-bracket me-2 w-20px"></i> Đăng xuất</a>
</div>

<!-- MAIN CONTENT -->
<div class="main-content">

    <!-- HEADER TOP -->
    <div class="top-header">
        <div class="dropdown">
            <a href="#" class="d-flex align-items-center text-decoration-none text-dark" data-bs-toggle="dropdown">
                <img src="https://ui-avatars.com/api/?name=${not empty sessionScope.acc ? sessionScope.acc.hoTen : 'Admin'}&background=random" alt="Avatar" width="32" height="32" class="rounded-circle me-2">
                <span class="fw-bold">${not empty sessionScope.acc ? sessionScope.acc.hoTen : 'Quản trị viên'}</span>
                <i class="fa-solid fa-chevron-down ms-2" style="font-size: 12px;"></i>
            </a>
            <ul class="dropdown-menu dropdown-menu-end">
                <li><a href="#" class="nav-link" data-bs-toggle="modal" data-bs-target="#adminProfileModal">
                    <i class="fa-solid fa-user-gear me-2 w-20px"></i> Cấu hình tài khoản
                </a></li>
                <li><hr class="dropdown-divider"></li>
                <li><a class="dropdown-item text-danger" href="${pageContext.request.contextPath}/logout">Đăng xuất</a></li>
            </ul>
        </div>
    </div>

    <div class="container-fluid px-4">

        <%
            String profileMsg = (String) session.getAttribute("profileMsg");
            String profileMsgType = (String) session.getAttribute("profileMsgType"); // "success" hoặc "danger"
            if (profileMsg != null) {
                session.removeAttribute("profileMsg");
                session.removeAttribute("profileMsgType");
        %>
        <div class="alert alert-<%= "success".equals(profileMsgType) ? "success" : "danger" %> alert-dismissible fade show mt-3 mb-3 shadow-sm" role="alert">
            <i class="fa-solid <%= "success".equals(profileMsgType) ? "fa-circle-check" : "fa-circle-exclamation" %> me-2"></i>
            <%= profileMsg %>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
        <%
            }
        %>

        <!-- PAGE HEADER -->
        <div class="d-flex justify-content-between align-items-center mb-4 mt-4">
            <div>
                <h4 class="fw-bold text-dark mb-1">Bảng điều khiển Trung tâm</h4>
                <p class="text-muted mb-0" style="font-size: 0.9rem;">Thống kê tình hình hoạt động của toàn bộ Ký túc xá.</p>
            </div>
            <a href="${pageContext.request.contextPath}/admin-export-excel" class="btn btn-primary fw-medium shadow-sm px-4">
                <i class="fa-solid fa-file-export me-2"></i> Xuất báo cáo Excel
            </a>
        </div>

        <!-- THỐNG KÊ TỔNG QUAN -->
        <div class="row g-4 mb-4">
            <div class="col-md-3">
                <div class="card stat-card h-100 p-3 d-flex flex-row align-items-center bg-primary bg-opacity-10 border border-primary border-opacity-25">
                    <div class="icon-box bg-primary text-white me-3 shadow-sm">
                        <i class="fa-solid fa-layer-group"></i>
                    </div>
                    <div>
                        <h3 class="fw-bold mb-0 text-primary">${total != null ? total : 0}</h3>
                        <span class="text-muted small fw-medium">Tổng sự cố tháng này</span>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card stat-card h-100 p-3 d-flex flex-row align-items-center bg-danger bg-opacity-10 border border-danger border-opacity-25">
                    <div class="icon-box bg-danger text-white me-3 shadow-sm">
                        <i class="fa-solid fa-user-clock"></i>
                    </div>
                    <div>
                        <h3 class="fw-bold mb-0 text-danger">${pending != null ? pending : 0}</h3>
                        <span class="text-muted small fw-medium">Chờ phân công xử lý</span>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card stat-card h-100 p-3 d-flex flex-row align-items-center bg-warning bg-opacity-10 border border-warning border-opacity-25">
                    <div class="icon-box bg-warning text-dark me-3 shadow-sm">
                        <i class="fa-solid fa-screwdriver-wrench"></i>
                    </div>
                    <div>
                        <h3 class="fw-bold mb-0 text-dark">${processing != null ? processing : 0}</h3>
                        <span class="text-muted small fw-medium">Đang tiến hành sửa chữa</span>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card stat-card h-100 p-3 d-flex flex-row align-items-center bg-success bg-opacity-10 border border-success border-opacity-25">
                    <div class="icon-box bg-success text-white me-3 shadow-sm">
                        <i class="fa-solid fa-users"></i>
                    </div>
                    <div>
                        <h3 class="fw-bold mb-0 text-success">${totalStudents != null ? totalStudents : 0}</h3>
                        <span class="text-muted small fw-medium">Tổng sinh viên nội trú</span>
                    </div>
                </div>
            </div>
        </div>

        <!-- BẢNG THEO DÕI SỰ CỐ TOÀN HỆ THỐNG -->
        <%
            String assignment = request.getParameter("assignment");
            if ("success".equals(assignment)) {
        %>
        <div class="alert alert-success" role="status">Đã phân công. Đang chờ nhân viên nhận việc.</div>
        <%
        } else if ("failed".equals(assignment)) {
        %>
        <div class="alert alert-danger" role="alert">Không thể phân công. Kiểm tra trạng thái sự cố và nhân viên được chọn.</div>
        <%
            }
        %>

        <div class="d-flex justify-content-between align-items-center mb-3 mt-5">
            <h5 class="fw-bold mb-0">Sự cố chờ điều phối & Phân công</h5>
            <div class="input-group" style="width: 300px;">
                <input type="text" class="form-control form-control-sm" placeholder="Tìm theo mã SC, tên SV...">
                <button class="btn btn-sm btn-outline-secondary"><i class="fa-solid fa-magnifying-glass"></i></button>
            </div>
        </div>

        <div class="card stat-card border-0 shadow-sm rounded-3 mb-4">
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0">
                        <thead class="table-light text-muted" style="font-size: 0.85rem;">
                        <tr>
                            <th class="ps-4 fw-medium py-3">MÃ SC</th>
                            <th class="fw-medium py-3">TIÊU ĐỀ SỰ CỐ</th>
                            <th class="fw-medium py-3">NGƯỜI BÁO CÁO</th>
                            <th class="fw-medium py-3">VỊ TRÍ</th>
                            <th class="fw-medium py-3">MỨC ĐỘ</th>
                            <th class="fw-medium py-3">TRẠNG THÁI</th>
                            <th class="fw-medium py-3 text-center">CHI TIẾT</th>
                            <th class="pe-4 fw-medium py-3 text-center">THAO TÁC</th>
                        </tr>
                        </thead>
                        <tbody>
                        <%
                            List<SuCo> listSuCo = (List<SuCo>) request.getAttribute("listSuCo");
                            if (listSuCo != null && !listSuCo.isEmpty()) {
                                for (SuCo task : listSuCo) {
                                    String badgeMucDo = "KHẨN CẤP".equals(task.getMucDo()) ? "danger" : ("TRUNG BÌNH".equals(task.getMucDo()) ? "warning" : "success");
                                    String badgeTrangThai = "Chờ xử lý".equals(task.getTrangThai()) ? "warning" : ("Đang xử lý".equals(task.getTrangThai()) ? "primary" : "success");
                                    String tenNguoiGui = task.getTenNguoiGui() != null ? task.getTenNguoiGui() : "Không rõ";
                        %>
                        <tr>
                            <td class="ps-4"><span class="fw-bold text-secondary">#SC0<%= task.getSuCoId() %></span></td>
                            <td>
                                <div class="fw-bold text-dark"><%= task.getTieuDe() %></div>
                                <div class="text-muted" style="font-size: 0.8rem;">Gửi lúc: <%= task.getNgayGui() %></div>
                            </td>
                            <td>
                                <div class="d-flex align-items-center">
                                    <img src="https://ui-avatars.com/api/?name=<%= java.net.URLEncoder.encode(tenNguoiGui, "UTF-8") %>&background=random" class="rounded-circle me-2" width="28">
                                    <span class="fw-medium"><%= tenNguoiGui %></span>
                                </div>
                            </td>
                            <td><span class="fw-medium text-dark"><i class="fa-solid fa-location-dot text-danger me-1"></i> <%= task.getViTriPhong() %></span></td>
                            <td><span class="badge bg-<%= badgeMucDo %> bg-opacity-10 text-<%= badgeMucDo %> border border-<%= badgeMucDo %>"><%= task.getMucDo() %></span></td>
                            <td><span class="badge bg-<%= badgeTrangThai %> <%= "Chờ xử lý".equals(task.getTrangThai()) ? "text-dark" : "text-white" %>"><%= task.getTrangThai() %></span></td>
                            <td class="text-center">
                                <button type="button" class="btn btn-sm btn-light text-primary border"
                                        data-bs-toggle="modal" data-bs-target="#detailModal<%= task.getSuCoId() %>"
                                        title="Xem chi tiết">
                                    <i class="fa-solid fa-eye"></i>
                                </button>
                            </td>
                            <td class="pe-4 text-center">
                                <button type="button" class="btn btn-sm btn-primary shadow-sm px-3"
                                        data-bs-toggle="modal" data-bs-target="#assignModal<%= task.getSuCoId() %>"
                                        title="Phân công xử lý">
                                    <i class="fa-solid fa-user-gear me-1"></i> Phân công
                                </button>
                            </td>
                        </tr>
                        <%
                            }
                        } else {
                        %>
                        <tr>
                            <td colspan="8" class="text-center py-4 text-muted">Hệ thống chưa có sự cố nào.</td>
                        </tr>
                        <% } %>
                        </tbody>
                    </table>
                </div>
                <c:set var="adminPaginationPath" value="/admin-home"/>
                <%@ include file="/WEB-INF/admin_pagination.jspf" %>
            </div>
        </div>

    </div> <!-- End container-fluid -->
</div> <!-- End main-content -->

<!-- MODAL ĐĂNG THÔNG BÁO TỪ ADMIN -->
<div class="modal fade" id="createNoticeModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header bg-primary text-white">
                <h5 class="modal-title fw-bold"><i class="fa-solid fa-bullhorn me-2"></i>Đăng Thông Báo Mới</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body p-4">
                <form action="${pageContext.request.contextPath}/create-thongbao" method="POST">
                    <div class="mb-3">
                        <label class="form-label fw-bold">Tiêu đề thông báo <span class="text-danger">*</span></label>
                        <input type="text" class="form-control" name="tieuDe" placeholder="VD: Lịch phun muỗi toàn KTX..." required>
                    </div>
                    <div class="mb-4">
                        <label class="form-label fw-bold">Nội dung chi tiết <span class="text-danger">*</span></label>
                        <textarea class="form-control" name="noiDung" rows="5" placeholder="Nhập nội dung thông báo gửi đến sinh viên..." required></textarea>
                    </div>
                    <div class="d-flex justify-content-end">
                        <button type="button" class="btn btn-light border me-2" data-bs-dismiss="modal">Hủy bỏ</button>
                        <button type="submit" class="btn btn-primary fw-bold">Phát hành ngay</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

<!-- VÒNG LẶP TẠO MODAL CHI TIẾT SỰ CỐ CHO TỪNG DÒNG (DÀNH CHO ADMIN) -->
<%
    if (listSuCo != null && !listSuCo.isEmpty()) {
        for (SuCo task : listSuCo) {
            String badgeMucDo = "KHẨN CẤP".equals(task.getMucDo()) ? "danger" : ("TRUNG BÌNH".equals(task.getMucDo()) ? "warning" : "success");
            String badgeTrangThai = "Chờ xử lý".equals(task.getTrangThai()) ? "warning" : ("Đang xử lý".equals(task.getTrangThai()) ? "primary" : "success");
            String tenNguoiGui = task.getTenNguoiGui() != null ? task.getTenNguoiGui() : "Không rõ";
            String sdtNguoiGui = task.getSoDienThoai() != null ? task.getSoDienThoai() : "Không có";
%>
<div class="modal fade" id="detailModal<%= task.getSuCoId() %>" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header bg-primary text-white">
                <h5 class="modal-title fw-bold"><i class="fa-solid fa-circle-info me-2"></i>Chi tiết sự cố #SC0<%= task.getSuCoId() %></h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body p-4 text-start">
                <h6 class="fw-bold text-primary mb-3"><%= task.getTieuDe() %></h6>
                <div class="mb-2"><strong>Người báo cáo:</strong> <span class="text-dark fw-bold"><%= tenNguoiGui %></span></div>
                <div class="mb-2">
                    <strong>SĐT Người báo:</strong>
                    <a href="tel:<%= sdtNguoiGui %>" class="text-decoration-none fw-bold text-primary">
                        <i class="fa-solid fa-phone fa-sm me-1"></i> <%= sdtNguoiGui %>
                    </a>
                </div>
                <div class="mb-2"><strong>Vị trí phòng:</strong> <span class="text-danger fw-medium"><%= task.getViTriPhong() %></span></div>
                <div class="mb-2"><strong>Mức độ:</strong> <span class="badge bg-<%= badgeMucDo %>"><%= task.getMucDo() %></span></div>
                <div class="mb-2"><strong>Trạng thái:</strong> <span class="badge bg-<%= badgeTrangThai %> <%= "Chờ xử lý".equals(task.getTrangThai()) ? "text-dark" : "text-white" %>"><%= task.getTrangThai() %></span></div>
                <div class="mb-2"><strong>Ngày báo cáo:</strong> <%= task.getNgayGui() %></div>
                <div class="mb-2">
                    <strong>Nhân viên phụ trách:</strong>
                    <%
                        String trangThaiNV = task.getTrangThai();
                        String tenNV = task.getTenNhanVien();
                        String sdtNV = task.getSdtNhanVien();
                        boolean daCoNV = !"Chờ xử lý".equals(trangThaiNV) && tenNV != null && !tenNV.trim().isEmpty();
                        if (daCoNV) {
                    %>
                    <span class="text-primary fw-medium"><%= tenNV %></span>
                    <% if (sdtNV != null && !sdtNV.trim().isEmpty()) { %>
                    - <a href="tel:<%= sdtNV %>" class="text-decoration-none"><i class="fa-solid fa-phone fa-xs me-1"></i><%= sdtNV %></a>
                    <% } %>
                    <%
                    } else {
                    %>
                    <span class="text-muted">---</span>
                    <%
                        }
                    %>
                </div>
                <hr>
                <div class="mb-1 fw-bold text-dark">Mô tả chi tiết từ sinh viên:</div>
                <div class="p-3 bg-light rounded border text-muted" style="font-size: 0.95rem;">
                    <%= task.getMoTa() != null ? task.getMoTa() : "Không có mô tả chi tiết." %>
                </div>
                <%
                    String repairNote = task.getGhiChuKyThuat();
                    if (repairNote != null && !repairNote.trim().isEmpty()) {
                %>
                <div class="mt-3 mb-1 fw-bold">Kết quả sửa chữa và vật tư thay thế</div>
                <div class="p-3 bg-light rounded border text-break" style="white-space: pre-wrap"><%= repairNote %></div>
                <%
                    }
                %>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary px-4" data-bs-dismiss="modal">Đóng</button>
            </div>
        </div>
    </div>
</div>
<%
        }
    }
%>

<!-- VÒNG LẶP TẠO MODAL PHÂN CÔNG CHO TỪNG SỰ CỐ -->
<%
    if (listSuCo != null && !listSuCo.isEmpty()) {
        for (SuCo task : listSuCo) {
            dao.SuCoDAO sDao = new dao.SuCoDAO();

            // LẤY ĐÚNG MÃ TỔ CỦA SỰ CỐ THAY VÌ FIX CỨNG SỐ 1
            java.util.List<model.TaiKhoan> listStaff = sDao.getStaffByTeam(task.getToId());
%>
<div class="modal fade" id="assignModal<%= task.getSuCoId() %>" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header bg-primary text-white">
                <h5 class="modal-title fw-bold"><i class="fa-solid fa-user-gear me-2"></i>Phân công xử lý sự cố #SC0<%= task.getSuCoId() %></h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <form action="${pageContext.request.contextPath}/assign-task" method="POST">
                <div class="modal-body p-4 text-start">
                    <input type="hidden" name="suCoId" value="<%= task.getSuCoId() %>">
                    <input type="hidden" name="page" value="${pageNumber}">
                    <h6 class="fw-bold text-primary mb-3"><%= task.getTieuDe() %></h6>
                    <div class="mb-3">
                        <label class="form-label fw-bold">Chọn nhân viên kỹ thuật phụ trách <span class="text-danger">*</span></label>
                        <select class="form-select" name="nhanVienId" required>
                            <option value="" selected disabled>-- Chọn nhân viên thuộc tổ --</option>
                            <%
                                if (listStaff != null && !listStaff.isEmpty()) {
                                    for (model.TaiKhoan staff : listStaff) {
                            %>
                            <option value="<%= staff.getTaiKhoanId() %>"><%= staff.getHoTen() %> (SĐT: <%= staff.getSoDienThoai() %>)</option>
                            <%
                                }
                            } else {
                            %>
                            <option value="" disabled>Không có nhân viên nào trong tổ này</option>
                            <% } %>
                        </select>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-light border px-4" data-bs-dismiss="modal">Hủy bỏ</button>
                    <button type="submit" class="btn btn-primary fw-bold px-4">Xác nhận phân công</button>
                </div>
            </form>
        </div>
    </div>
</div>
<%
        }
    }
%>

<!-- MODAL CẤU HÌNH TÀI KHOẢN ADMIN -->
<div class="modal fade" id="adminProfileModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content border-0 shadow">
            <div class="modal-header bg-primary text-white">
                <h5 class="modal-title fw-bold">
                    <i class="fa-solid fa-user-gear me-2"></i>Cấu hình tài khoản
                </h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>

            <div class="modal-body p-4">
                <ul class="nav nav-tabs mb-3" role="tablist">
                    <li class="nav-item" role="presentation">
                        <button class="nav-link active fw-medium" id="tabBtnProfile" data-bs-toggle="tab" data-bs-target="#tabProfileInfo" type="button">
                            Thông tin cá nhân
                        </button>
                    </li>
                    <li class="nav-item" role="presentation">
                        <button class="nav-link fw-medium" id="tabBtnPass" data-bs-toggle="tab" data-bs-target="#tabChangePass" type="button">
                            Đổi mật khẩu
                        </button>
                    </li>
                </ul>

                <div class="tab-content">
                    <!-- TAB 1: THÔNG TIN CÁ NHÂN -->
                    <div class="tab-pane fade show active" id="tabProfileInfo">
                        <% String pUpdate = request.getParameter("profileUpdate"); %>
                        <% if ("success".equals(pUpdate)) { %>
                        <div class="alert alert-success py-2 small"><i class="fa-solid fa-circle-check me-1"></i> Cập nhật thông tin thành công!</div>
                        <% } else if ("failed".equals(pUpdate)) { %>
                        <div class="alert alert-danger py-2 small"><i class="fa-solid fa-circle-exclamation me-1"></i> Cập nhật thất bại. Vui lòng kiểm tra lại!</div>
                        <% } %>

                        <form id="adminProfileForm" action="${pageContext.request.contextPath}/update-profile" data-validation="profile" method="POST">
                            <fieldset id="adminProfileFieldset" disabled>
                                <div class="mb-3">
                                    <label class="form-label fw-bold small">Tên đăng nhập</label>
                                    <input type="text" class="form-control bg-light" value="${sessionScope.acc.tenDangNhap}" readonly>
                                </div>
                                <div class="mb-3">
                                    <label class="form-label fw-bold small">Họ và tên <span class="text-danger">*</span></label>
                                    <input type="text" class="form-control" name="fullName" maxlength="100" value="${sessionScope.acc.hoTen}" required>
                                </div>
                                <div class="mb-3">
                                    <label class="form-label fw-bold small">Email</label>
                                    <input type="email" class="form-control" name="email" maxlength="100" value="${sessionScope.acc.email}" placeholder="Nhập địa chỉ email...">
                                </div>
                                <div class="mb-3">
                                    <label class="form-label fw-bold small">Số điện thoại</label>
                                    <input type="tel" inputmode="numeric" class="form-control" name="sdt" maxlength="10" value="${sessionScope.acc.soDienThoai}" placeholder="Nhập số điện thoại...">
                                </div>
                            </fieldset>

                            <div class="d-flex justify-content-end gap-2 mt-4">
                                <button type="button" class="btn btn-light border" data-bs-dismiss="modal" id="btnCloseAdminProfile">Đóng</button>
                                <button type="button" class="btn btn-outline-primary fw-bold" id="btnEditAdminProfile">
                                    <i class="fa-solid fa-pen-to-square me-1"></i> Chỉnh sửa thông tin
                                </button>
                                <button type="button" class="btn btn-light border d-none" id="btnCancelAdminProfile">Hủy</button>
                                <button type="submit" class="btn btn-primary fw-bold px-4 d-none" id="btnSaveAdminProfile">
                                    <i class="fa-solid fa-floppy-disk me-1"></i> Lưu thay đổi
                                </button>
                            </div>
                        </form>
                    </div>

                    <!-- TAB 2: ĐỔI MẬT KHẨU -->
                    <div class="tab-pane fade" id="tabChangePass">
                        <%
                            String passMsg = request.getParameter("msg");
                            String passErr = request.getParameter("error");
                            String passErrDetail = request.getParameter("passError");
                        %>
                        <% if ("pass_success".equals(passMsg)) { %>
                        <div class="alert alert-success py-2 small"><i class="fa-solid fa-circle-check me-1"></i> Đổi mật khẩu thành công!</div>
                        <% } else if ("mismatch".equals(passErrDetail)) { %>
                        <div class="alert alert-danger py-2 small"><i class="fa-solid fa-circle-exclamation me-1"></i> Mật khẩu xác nhận không khớp!</div>
                        <% } else if ("short".equals(passErrDetail)) { %>
                        <div class="alert alert-danger py-2 small"><i class="fa-solid fa-circle-exclamation me-1"></i> Mật khẩu mới phải có ít nhất 6 ký tự!</div>
                        <% } else if ("empty".equals(passErrDetail)) { %>
                        <div class="alert alert-danger py-2 small"><i class="fa-solid fa-circle-exclamation me-1"></i> Vui lòng nhập đầy đủ thông tin!</div>
                        <% } %>

                        <form action="${pageContext.request.contextPath}/change-password" data-validation="password" method="POST">
                            <div class="mb-3">
                                <label class="form-label fw-bold small">Mật khẩu hiện tại <span class="text-danger">*</span></label>
                                <input type="password" class="form-control <%= "wrong_old_pass".equals(passErr) ? "is-invalid" : "" %>" name="oldPass" required>
                                <div class="invalid-feedback">Mật khẩu hiện tại không chính xác!</div>
                            </div>
                            <div class="mb-3">
                                <label class="form-label fw-bold small">Mật khẩu mới <span class="text-danger">*</span></label>
                                <input type="password" class="form-control" name="newPass" minlength="6" maxlength="72" required>
                            </div>
                            <div class="mb-3">
                                <label class="form-label fw-bold small">Xác nhận mật khẩu mới <span class="text-danger">*</span></label>
                                <input type="password" class="form-control" name="confirmPass" required>
                            </div>
                            <div class="d-flex justify-content-end gap-2 mt-4">
                                <button type="button" class="btn btn-light border" data-bs-dismiss="modal">Đóng</button>
                                <button type="submit" class="btn btn-primary fw-bold px-4">Đổi mật khẩu</button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
    document.addEventListener("DOMContentLoaded", function () {
        const modalEl = document.getElementById("adminProfileModal");
        const form = document.getElementById("adminProfileForm");
        const fieldset = document.getElementById("adminProfileFieldset");
        const btnEdit = document.getElementById("btnEditAdminProfile");
        const btnSave = document.getElementById("btnSaveAdminProfile");
        const btnCancel = document.getElementById("btnCancelAdminProfile");
        const btnClose = document.getElementById("btnCloseAdminProfile");

        function setEditMode(editing) {
            fieldset.disabled = !editing;
            btnEdit.classList.toggle("d-none", editing);
            btnClose.classList.toggle("d-none", editing);
            btnSave.classList.toggle("d-none", !editing);
            btnCancel.classList.toggle("d-none", !editing);
        }

        btnEdit.addEventListener("click", function () {
            setEditMode(true);
            form.elements.fullName.focus();
        });

        btnCancel.addEventListener("click", function () {
            form.reset();
            setEditMode(false);
        });

        modalEl.addEventListener("hidden.bs.modal", function () {
            form.reset();
            setEditMode(false);
        });

        // Tự động mở lại Modal và chuyển đúng Tab khi có thông báo
        const params = new URLSearchParams(window.location.search);
        if (params.has("profileUpdate")) {
            bootstrap.Modal.getOrCreateInstance(modalEl).show();
        } else if (params.get("msg") === "pass_success" || params.get("error") === "wrong_old_pass" || params.has("passError")) {
            bootstrap.Tab.getOrCreateInstance(document.getElementById("tabBtnPass")).show();
            bootstrap.Modal.getOrCreateInstance(modalEl).show();
        }
    });
</script>

<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

<script src="${pageContext.request.contextPath}/js/form-validation.js"></script>
</body>
</html>