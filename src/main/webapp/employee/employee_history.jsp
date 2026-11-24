<%@ taglib prefix="repair" uri="jakarta.tags.core" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="model.SuCo" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Lịch Sử Công Việc - Tổ Kỹ Thuật KTX</title>
    <!-- Bootstrap 5 -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- FontAwesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/incident-pagination.css">
    <style>
        body {
            background-color: #f0f2f5;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            overflow-x: hidden;
        }
        /* Sidebar Styles */
        .sidebar {
            width: 260px;
            background-color: #12443f;
            height: 100vh;
            position: fixed;
            left: 0;
            top: 0;
            border-right: 1px solid #e0e0e0;
        }
        .main-content {
            margin-left: 260px;
            min-height: 100vh;
            padding-bottom: 30px;
        }
        .sidebar .nav-link {
            color: #edf8f5;
            padding: 12px 20px;
            font-weight: 500;
            border-left: 3px solid transparent;
        }
        .sidebar .nav-link:hover, .sidebar .nav-link:focus-visible {
            background-color: #1b544d;
        }
        .sidebar .nav-link.active {
            background-color: #21645c;
            color: #edf8f5;
            border-left-color: #6ee7cb;
        }
        .sidebar .nav-link.sidebar-logout {
            color: #ffb4b4;
        }
        .sidebar .sidebar-brand-icon {
            color: #6ee7cb;
        }
        .sidebar-heading {
            font-size: 0.75rem;
            text-transform: uppercase;
            color: #a8cbc2;
            font-weight: bold;
            padding: 10px 20px;
            margin-top: 15px;
        }
        .w-20px {
            width: 22px;
            text-align: center;
        }
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
        .filter-btn.active {
            font-weight: bold;
            border-color: #0d6efd;
            color: #0d6efd;
            background-color: #f8f9fa;
        }
        .history-search {
            flex: 0 1 20rem;
            min-width: min(100%, 16rem);
        }
        @media (max-width: 991.98px) {
            .history-search {
                flex-basis: 100%;
            }
        }
        @media (min-width: 992px) {
            .sidebar {
                z-index: 1000;
            }
        }
        .sidebar.offcanvas-lg {
            background-color: #12443f !important;
        }
        @media (max-width: 991.98px) {
            .sidebar.offcanvas-lg {
                --bs-offcanvas-width: min(260px, 90vw);
                height: 100dvh;
            }
            .main-content {
                margin-left: 0;
            }
            .top-header {
                justify-content: space-between;
                padding: 0 1rem;
            }
        }
        @media (hover: hover) and (prefers-reduced-motion: no-preference) {
            .history-table-card {
                transition: transform 0.2s;
            }
            .history-table-card:hover {
                transform: translateY(-3px);
            }
        }
    </style>
</head>
<body>

<!-- SIDEBAR NHÂN VIÊN -->
<div class="sidebar offcanvas-lg offcanvas-start d-flex flex-column" id="employeeSidebar" tabindex="-1" aria-labelledby="employeeSidebarTitle" style="overflow-y: auto;">
    <div class="d-flex align-items-center p-3" style="height: 60px; border-bottom: 1px solid rgba(237, 248, 245, .2);">
        <i class="fa-solid fa-screwdriver-wrench fs-4 sidebar-brand-icon me-2"></i>
        <h5 id="employeeSidebarTitle" class="mb-0 fw-bold text-white" style="font-size: 1.1rem;">TỔ KỸ THUẬT</h5>
        <button type="button" class="btn-close btn-close-white d-lg-none ms-auto" data-bs-dismiss="offcanvas"
                data-bs-target="#employeeSidebar" aria-label="Đóng menu"></button>
    </div>

    <div class="sidebar-heading">Tổng quan</div>
    <a href="${pageContext.request.contextPath}/employee-home" class="nav-link"><i class="fa-solid fa-chart-pie me-2 w-20px"></i> Bảng điều khiển</a>

    <div class="sidebar-heading">Quản lý công việc</div>
    <a href="${pageContext.request.contextPath}/employee-home?filter=pending#work-list" class="nav-link">
        <span><i class="fa-solid fa-clipboard-list me-2 w-20px"></i> Chờ xử lý</span>
        <span class="badge bg-danger rounded-pill">${pending}</span>
    </a>
    <a href="${pageContext.request.contextPath}/employee-home?filter=processing#work-list" class="nav-link"><i class="fa-solid fa-person-digging me-2 w-20px"></i> Đang xử lý</a>
    <!-- Active state cho trang lịch sử công việc nhân viên -->
    <a href="${pageContext.request.contextPath}/employee-history" class="nav-link active"><i class="fa-solid fa-clock-rotate-left me-2 w-20px"></i> Lịch sử công việc</a>

    <a href="${pageContext.request.contextPath}/employee-home?view=statistics" class="nav-link ${statisticsView ? 'active' : ''}">
        <i class="fa-solid fa-chart-simple me-2 w-20px" aria-hidden="true"></i> Thống kê công việc
    </a>
    <a href="${pageContext.request.contextPath}/employee-home?view=team" class="nav-link ${teamView ? 'active' : ''}">
        <i class="fa-solid fa-users me-2 w-20px" aria-hidden="true"></i> Đồng nghiệp cùng tổ
    </a>
    <a href="#" class="nav-link" data-employee-modal="#maintenanceNoticeModal">
        <i class="fa-solid fa-bullhorn me-2 w-20px" aria-hidden="true"></i> Thông báo bảo trì
    </a>
    <div class="sidebar-heading">Hồ sơ cá nhân</div>
    <a href="#" class="nav-link" data-employee-modal="#profileModal"><i class="fa-regular fa-user me-2 w-20px"></i> Thông tin cá nhân</a>
    <a href="#" class="nav-link" data-employee-modal="#changePassModal"><i class="fa-solid fa-shield-halved me-2 w-20px"></i> Đổi mật khẩu</a>
    <a href="${pageContext.request.contextPath}/logout" class="nav-link sidebar-logout mt-3 mb-4"><i class="fa-solid fa-right-from-bracket me-2 w-20px"></i> Đăng xuất</a>
</div>

<!-- MAIN CONTENT -->
<div class="main-content">

    <!-- HEADER TOP -->
    <div class="top-header">
        <button type="button" id="employeeMenuButton" class="btn btn-outline-primary d-lg-none"
                data-bs-toggle="offcanvas" data-bs-target="#employeeSidebar"
                aria-controls="employeeSidebar" aria-label="Mở menu nhân viên">
            <i class="fa-solid fa-bars" aria-hidden="true"></i>
        </button>
        <div class="dropdown">
            <a href="#" class="d-flex align-items-center text-decoration-none text-dark" data-bs-toggle="dropdown">
                <img src="https://ui-avatars.com/api/?name=${not empty sessionScope.acc ? sessionScope.acc.hoTen : 'NV'}&background=random" alt="Avatar" width="32" height="32" class="rounded-circle me-2">
                <span class="fw-bold">${not empty sessionScope.acc ? sessionScope.acc.hoTen : 'Trần Văn Kỹ Thuật'}</span>
                <i class="fa-solid fa-chevron-down ms-2" style="font-size: 12px;"></i>
            </a>
            <ul class="dropdown-menu dropdown-menu-end">
                <li><a class="dropdown-item" href="#" data-bs-toggle="modal" data-bs-target="#profileModal">Hồ sơ nhân viên</a></li>
                <li><hr class="dropdown-divider"></li>
                <li><a class="dropdown-item text-danger" href="${pageContext.request.contextPath}/logout">Đăng xuất</a></li>
            </ul>
        </div>
    </div>

    <div class="container-fluid px-4 mt-4">
        <repair:if test="${param.maintenanceNotice == 'success'}">
            <div class="alert alert-success mt-3" role="status">Đã đăng thông báo bảo trì cho sinh viên.</div>
        </repair:if>

        <h4 class="fw-bold text-dark mb-4"><i class="fa-solid fa-clock-rotate-left text-primary me-2"></i>Lịch sử công việc kỹ thuật</h4>

        <!-- TÙY CHỈNH LỌC TRẠNG THÁI -->
        <% String currentFilter = request.getParameter("filter"); %>
        <div class="d-flex flex-wrap align-items-center gap-2 mb-4">
            <div class="btn-group flex-wrap shadow-sm" role="group" aria-label="Lọc theo trạng thái">
                <a href="?filter=all" class="btn btn-outline-secondary filter-btn <%= (currentFilter == null || currentFilter.equals("all")) ? "active" : "" %>">Tất cả</a>
                <a href="?filter=pending" class="btn btn-outline-secondary filter-btn <%= "pending".equals(currentFilter) ? "active text-warning" : "" %>">Chờ xử lý</a>
                <a href="?filter=processing" class="btn btn-outline-secondary filter-btn <%= "processing".equals(currentFilter) ? "active text-primary" : "" %>">Đang xử lý</a>
                <a href="?filter=done" class="btn btn-outline-secondary filter-btn <%= "done".equals(currentFilter) ? "active text-success" : "" %>">Đã hoàn thành</a>
            </div>
            <div class="position-relative history-search ms-auto">
                <i class="fa-solid fa-magnifying-glass position-absolute top-50 start-0 translate-middle-y ms-3 text-primary pe-none" aria-hidden="true"></i>
                <input type="search" id="historySearch" class="form-control rounded-pill ps-5 pe-3 shadow-sm"
                       aria-label="Tìm theo mã sự cố, tiêu đề hoặc vị trí"
                       placeholder="Tìm theo mã, tiêu đề, phòng..." maxlength="100">
            </div>
            <div class="position-relative">
                <label for="historyDate" class="position-absolute top-50 start-0 translate-middle-y ms-3 text-primary mb-0 pe-none" title="Lọc theo ngày gửi"><i class="fa-regular fa-calendar" aria-hidden="true"></i><span class="visually-hidden">Lọc theo ngày gửi</span></label>
                <input type="date" id="historyDate" class="form-control w-auto rounded-pill ps-5 pe-3 shadow-sm">
            </div>
        </div>
        <p id="historySearchStatus" class="visually-hidden" role="status"></p>

        <!-- BẢNG LỊCH SỬ CÔNG VIỆC -->
        <div class="card history-table-card border-0 shadow-sm rounded-3 mb-4">
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0">
                        <thead class="table-light text-muted" style="font-size: 0.85rem;">
                        <tr>
                            <th class="ps-4 fw-medium py-3">MÃ SC</th>
                            <th class="fw-medium py-3">TIÊU ĐỀ SỰ CỐ</th>
                            <th class="fw-medium py-3">VỊ TRÍ</th>
                            <th class="fw-medium py-3">MỨC ĐỘ</th>
                            <th class="fw-medium py-3">SĐT SINH VIÊN</th>
                            <th class="fw-medium py-3">NGÀY GỬI</th>
                            <th class="fw-medium py-3">TRẠNG THÁI</th>
                            <th class="pe-4 fw-medium py-3 text-center">CHI TIẾT</th>
                        </tr>
                        </thead>
                        <tbody>
                        <%
                            List<SuCo> historyList = (List<SuCo>) request.getAttribute("historyList");
                            if (historyList != null && !historyList.isEmpty()) {
                                for (SuCo task : historyList) {
                                    String badgeMucDo = "KHẨN CẤP".equals(task.getMucDo()) ? "danger" : ("TRUNG BÌNH".equals(task.getMucDo()) ? "warning" : "success");
                                    String badgeTrangThai = "Chờ xử lý".equals(task.getTrangThai()) ? "warning" : ("Đang xử lý".equals(task.getTrangThai()) ? "primary" : "success");
                        %>
                        <tr class="history-incident" data-report-date="<%= task.getNgayGui() == null ? "" : task.getNgayGui().toLocalDateTime().toLocalDate() %>">
                            <td class="ps-4"><span class="fw-bold text-secondary">#SC0<%= task.getSuCoId() %></span></td>
                            <td>
                                <div class="fw-bold text-dark"><%= task.getTieuDe() %></div>
                            </td>
                            <td><span class="fw-medium text-dark"><i class="fa-solid fa-location-dot text-danger me-1"></i> <%= task.getViTriPhong() %></span></td>
                            <td><span class="badge bg-<%= badgeMucDo %> bg-opacity-10 text-<%= badgeMucDo %> border border-<%= badgeMucDo %>"><%= task.getMucDo() %></span></td>
                            <td>
                                <a href="tel:<%= task.getSoDienThoai() != null ? task.getSoDienThoai().replace(".", "") : "" %>" class="text-decoration-none fw-medium text-primary">
                                    <i class="fa-solid fa-phone fa-sm me-1"></i> <%= task.getSoDienThoai() %>
                                </a>
                            </td>
                            <td class="text-muted" style="font-size: 0.9rem;"><%= task.getNgayGui() %></td>
                            <td><span class="badge bg-<%= badgeTrangThai %> <%= "Chờ xử lý".equals(task.getTrangThai()) ? "text-dark" : "text-white" %>"><%= task.getTrangThai() %></span></td>
                            <td class="pe-4 text-center">
                                <button type="button" class="btn btn-sm btn-light text-primary border"
                                        data-bs-toggle="modal" data-bs-target="#historyDetailModal<%= task.getSuCoId() %>" title="Xem chi tiết">
                                    <i class="fa-solid fa-eye"></i>
                                </button>
                            </td>
                        </tr>
                        <%
                            }
                        } else {
                        %>
                        <tr>
                            <td colspan="8" class="text-center py-5 text-muted">Không tìm thấy công việc nào trong mục này.</td>
                        </tr>
                        <% } %>
                        <tr id="historyNoMatches" hidden>
                            <td colspan="8" class="text-center py-5 text-muted">Không có sự cố phù hợp với bộ lọc.</td>
                        </tr>
                        </tbody>
                    </table>
                </div>
                <div class="incident-pagination--employee">
                    <%@ include file="/WEB-INF/incident_pagination.jspf" %>
                </div>
            </div>
        </div>

    </div>
</div>

<!-- VÒNG LẶP MODAL CHI TIẾT LỊCH SỬ CÔNG VIỆC -->
<%
    if (historyList != null && !historyList.isEmpty()) {
        for (SuCo task : historyList) {
            String badgeMucDo = "KHẨN CẤP".equals(task.getMucDo()) ? "danger" : ("TRUNG BÌNH".equals(task.getMucDo()) ? "warning" : "success");
            String badgeTrangThai = "Chờ xử lý".equals(task.getTrangThai()) ? "warning" : ("Đang xử lý".equals(task.getTrangThai()) ? "primary" : "success");
%>
<div class="modal fade" id="historyDetailModal<%= task.getSuCoId() %>" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header bg-primary text-white">
                <h5 class="modal-title fw-bold"><i class="fa-solid fa-circle-info me-2"></i>Chi tiết sự cố #SC0<%= task.getSuCoId() %></h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body p-4 text-start">
                <h6 class="fw-bold text-primary mb-3"><%= task.getTieuDe() %></h6>
                <div class="mb-2"><strong>Vị trí phòng:</strong> <span class="text-danger"><%= task.getViTriPhong() %></span></div>
                <div class="mb-2"><strong>Mức độ:</strong> <span class="badge bg-<%= badgeMucDo %>"><%= task.getMucDo() %></span></div>
                <div class="mb-2"><strong>Trạng thái:</strong> <span class="badge bg-<%= badgeTrangThai %>"><%= task.getTrangThai() %></span></div>
                <div class="mb-2"><strong>SĐT Sinh viên:</strong> <a href="tel:<%= task.getSoDienThoai() %>" class="text-decoration-none fw-bold"><%= task.getSoDienThoai() %></a></div>
                <div class="mb-2"><strong>Ngày báo cáo:</strong> <%= task.getNgayGui() %></div>
                <hr>
                <div class="mb-1 fw-bold text-dark">Mô tả chi tiết từ sinh viên:</div>
                <div class="p-3 bg-light rounded border text-muted" style="font-size: 0.95rem;">
                    <%= task.getMoTa() %>
                </div>
                <repair:set var="repairNote" value="<%= task.getGhiChuKyThuat() %>"/>
                <repair:if test="${not empty repairNote}">
                    <div class="mt-3 mb-1 fw-bold">Kết quả sửa chữa và vật tư thay thế</div>
                    <div class="p-3 bg-light rounded border text-break" style="white-space: pre-wrap"><repair:out value="${repairNote}"/></div>
                </repair:if>
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

<%@ include file="/WEB-INF/employee_account_modals.jspf" %>
<%@ include file="/WEB-INF/employee_maintenance_notice.jspf" %>

<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/js/incident-pagination.js"></script>
<script>
    const historySearch = document.getElementById('historySearch');
    const historyDate = document.getElementById('historyDate');
    const historyPagination = createIncidentPagination('.history-incident', 'historyNoMatches');
    const historyStatusLinks = document.querySelectorAll('.filter-btn');

    function normalizeHistorySearch(text) {
        return text.toLowerCase().normalize('NFD').replace(/[\u0300-\u036f]/g, '').replace(/đ/g, 'd');
    }

    function updateHistorySearch() {
        const value = historySearch.value.trim();
        const date = historyDate.value;
        const terms = normalizeHistorySearch(value).split(/\s+/).filter(Boolean);
        const matches = historyPagination.update(row => {
            const searchable = normalizeHistorySearch(Array.from(row.cells).slice(0, 3)
                .map(cell => cell.textContent.trim()).join(' '));
            return (!date || row.dataset.reportDate === date) && terms.every(term => searchable.includes(term));
        });
        document.getElementById('historySearchStatus').textContent = value || date ? matches + ' sự cố phù hợp.' : '';
        historyStatusLinks.forEach(link => {
            const url = new URL(link.href);
            if (value) url.searchParams.set('q', value);
            else url.searchParams.delete('q');
            if (date) url.searchParams.set('date', date);
            else url.searchParams.delete('date');
            link.href = url.href;
        });
    }

    const historySearchParams = new URLSearchParams(location.search);
    historySearch.value = (historySearchParams.get('q') || '').slice(0, 100);
    historyDate.value = historySearchParams.get('date') || '';
    historySearch.addEventListener('input', updateHistorySearch);
    historyDate.addEventListener('input', updateHistorySearch);
    updateHistorySearch();
</script>
<%@ include file="/WEB-INF/employee_sidebar_script.jspf" %>
<script src="${pageContext.request.contextPath}/js/form-validation.js"></script>
</body>
</html>