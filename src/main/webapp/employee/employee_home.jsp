<%@ taglib prefix="staff" uri="jakarta.tags.core" %>
<%@ taglib prefix="staffFn" uri="jakarta.tags.functions" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="model.SuCo" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Trang Nhân Viên - KTX Support</title>
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
        /* Sidebar Styles (Đã bỏ shadow, dùng border liền mạch) */
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
        /* Top Header (Đã ghim cố định) */
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
        /* Stat Cards */
        .stat-card {
            border: none;
            border-radius: 12px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.03);
            transition: transform 0.2s;
        }
        .stat-card:hover {
            transform: translateY(-3px);
        }
        .icon-box {
            width: 45px;
            height: 45px;
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.2rem;
        }
        .work-search {
            flex: 0 1 20rem;
            min-width: min(100%, 16rem);
        }
        @media (max-width: 991.98px) {
            .work-search {
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
        .employee-chart {
            position: relative;
            height: clamp(15rem, 32vw, 19rem);
        }
        .employee-chart-key {
            width: .65rem;
            height: .65rem;
            background: var(--key-color);
        }
        .statistics-heading-icon {
            color: #21645c;
            background: #dcefeb;
        }
        .work-summary {
            background: linear-gradient(110deg, #13294b, #1a4477);
            color: #fff;
        }
        .work-summary dt {
            color: #d9e7fa;
        }
        .work-summary-item + .work-summary-item {
            border-top: 1px solid rgba(255, 255, 255, .2);
        }
        @media (min-width: 768px) {
            .work-summary-item + .work-summary-item {
                border-top: 0;
                border-left: 1px solid rgba(255, 255, 255, .2);
            }
        }
        @media (hover: hover) and (prefers-reduced-motion: no-preference) {
            .team-table-card {
                transition: transform 0.2s;
            }
            .team-table-card:hover {
                transform: translateY(-3px);
            }
        }
        .team-heading {
            background: linear-gradient(110deg, #10233f, #1d4674);
        }
        .team-heading-name {
            color: #d4e4f7;
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
    <a href="${pageContext.request.contextPath}/employee-home" class="nav-link ${empty workFilter and not teamView and not statisticsView ? 'active' : ''}">
        <i class="fa-solid fa-chart-pie me-2 w-20px"></i> Bảng điều khiển
    </a>
    <div class="sidebar-heading">Quản lý công việc</div>
    <a href="${pageContext.request.contextPath}/employee-home?filter=pending#work-list" class="nav-link ${workFilter == 'pending' ? 'active' : ''}">
        <span><i class="fa-solid fa-clipboard-list me-2 w-20px"></i> Chờ xử lý</span>
        <span class="badge bg-danger rounded-pill" data-work-count="sidebar">${sidebarPending ne null ? sidebarPending : pending}</span>
    </a>
    <a href="${pageContext.request.contextPath}/employee-home?filter=processing#work-list" class="nav-link ${workFilter == 'processing' ? 'active' : ''}"><i class="fa-solid fa-person-digging me-2 w-20px"></i> Đang xử lý</a>
    <a href="${pageContext.request.contextPath}/employee-history" class="nav-link">
        <i class="fa-solid fa-clock-rotate-left me-2 w-20px"></i> Lịch sử công việc
    </a>
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

    <div class="container-fluid px-4 ${empty workFilter and not teamView and not statisticsView ? '' : 'pt-4'}">
        <staff:if test="${param.maintenanceNotice == 'success'}">
            <div class="alert alert-success mt-3" role="status">Đã đăng thông báo bảo trì cho sinh viên.</div>
        </staff:if>

        <staff:if test="${empty workFilter and not teamView and not statisticsView}">
            <!-- PAGE HEADER -->
            <div class="d-flex justify-content-between align-items-center mb-4 mt-4">
                <div>
                    <h4 class="fw-bold text-dark mb-1">Bảng điều khiển công việc</h4>
                    <p class="text-muted mb-0" style="font-size: 0.9rem;">
                        Xin chào KTV <strong class="text-primary">${not empty sessionScope.acc ? sessionScope.acc.hoTen : 'Trần Văn Kỹ Thuật'}</strong>. Khu vực phụ trách: <strong>Tòa A1, A2</strong>.
                    </p>
                </div>
                <button class="btn btn-outline-primary fw-medium shadow-sm rounded-pill px-4">
                    <i class="fa-solid fa-print me-2"></i> In báo cáo ngày
                </button>
            </div>

        </staff:if>

        <staff:if test="${statisticsView}">
            <div class="statistics-header d-flex flex-wrap align-items-center justify-content-between gap-3 mb-4">
                <h4 class="d-flex align-items-center gap-3 fw-bold text-dark mb-0">
                    <span class="statistics-heading-icon rounded-3 p-2 fs-5" aria-hidden="true"><i class="fa-solid fa-chart-simple"></i></span>
                    Thống kê công việc
                </h4>
                <div class="d-flex flex-wrap align-items-center gap-2">
                    <form method="get" action="${pageContext.request.contextPath}/employee-home" class="position-relative">
                        <input type="hidden" name="view" value="statistics">
                        <label for="statisticsMonth" class="position-absolute top-50 start-0 translate-middle-y ms-3 text-primary mb-0 pe-none">
                            <i class="fa-regular fa-calendar" aria-hidden="true"></i>
                            <span class="visually-hidden">Tháng thống kê</span>
                        </label>
                        <input id="statisticsMonth" name="month" type="month"
                               class="form-control w-auto rounded-pill ps-5 pe-3 shadow-sm"
                               value="${statisticsMonth}"
                               onchange="if (this.validity.valid) this.form.requestSubmit()">
                    </form>
                </div>
            </div>
        </staff:if>

        <staff:if test="${empty workFilter and not teamView and not statisticsView}">
            <!-- THỐNG KÊ NHANH CỦA NHÂN VIÊN -->
            <div class="row g-4 mb-4">
                <div class="col-md-4">
                    <div class="card stat-card h-100 p-3 d-flex flex-row align-items-center" style="border-left: 4px solid #ffc107;">
                        <div class="icon-box bg-warning bg-opacity-10 text-warning me-3">
                            <i class="fa-solid fa-clipboard-question"></i>
                        </div>
                        <div>
                            <h4 class="fw-bold mb-0" data-work-count="pending">${pending != null ? pending : 0}</h4>
                            <span class="text-muted small">Sự cố chờ tiếp nhận</span>
                        </div>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="card stat-card h-100 p-3 d-flex flex-row align-items-center" style="border-left: 4px solid #0d6efd;">
                        <div class="icon-box bg-primary bg-opacity-10 text-primary me-3">
                            <i class="fa-solid fa-person-digging"></i>
                        </div>
                        <div>
                            <h4 class="fw-bold mb-0" data-work-count="processing">${processing != null ? processing : 0}</h4>
                            <span class="text-muted small">Công việc đang xử lý</span>
                        </div>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="card stat-card h-100 p-3 d-flex flex-row align-items-center" style="border-left: 4px solid #198754;">
                        <div class="icon-box bg-success bg-opacity-10 text-success me-3">
                            <i class="fa-solid fa-check-double"></i>
                        </div>
                        <div>
                            <h4 class="fw-bold mb-0" data-work-count="done">${done != null ? done : 0}</h4>
                            <span class="text-muted small">Đã hoàn thành (Tháng này)</span>
                        </div>
                    </div>
                </div>
            </div>
        </staff:if>

        <staff:choose>
            <staff:when test="${param.statusUpdate == 'success'}">
                <div class="alert alert-success" role="status">Đã cập nhật sự cố.</div>
            </staff:when>
            <staff:when test="${param.statusUpdate == 'note'}">
                <div class="alert alert-warning" role="alert">Nhập ghi chú sửa chữa từ 1 đến 2.000 ký tự.</div>
            </staff:when>
            <staff:when test="${param.statusUpdate == 'failed'}">
                <div class="alert alert-danger" role="alert">Không thể cập nhật sự cố. Hãy kiểm tra trạng thái hiện tại và thử lại.</div>
            </staff:when>
        </staff:choose>

        <staff:if test="${statisticsView}">
            <div class="work-summary rounded-4 p-3 p-md-4 mb-4">
                <dl class="row g-0 mb-0">
                    <div class="col-12 col-md-4 work-summary-item px-3 py-2">
                        <dt class="fw-medium"><i class="fa-solid fa-layer-group me-2" aria-hidden="true"></i>Sự cố đang chờ và đang xử lý</dt>
                        <dd class="fs-2 fw-bold mb-0">${pending + processing}</dd>
                    </div>
                    <div class="col-12 col-md-4 work-summary-item px-3 py-2">
                        <dt class="fw-medium"><i class="fa-solid fa-triangle-exclamation me-2" aria-hidden="true"></i>Sự cố khẩn cấp</dt>
                        <dd class="fs-2 fw-bold mb-0 text-warning">${openByPriority['Khẩn cấp']}</dd>
                    </div>
                    <div class="col-12 col-md-4 work-summary-item px-3 py-2">
                        <dt class="fw-medium"><i class="fa-solid fa-check-double me-2" aria-hidden="true"></i>${empty statisticsMonth ? 'Đã hoàn thành' : 'Đã hoàn thành trong tháng'}</dt>
                        <dd class="fs-2 fw-bold mb-0">${done}</dd>
                    </div>
                </dl>
            </div>
            <staff:choose>
                <staff:when test="${pending + processing + done == 0}">
                    <p class="alert alert-light border" role="status">Không có số liệu công việc${empty statisticsMonth ? '' : ' cho tháng '.concat(statisticsMonthLabel)}.</p>
                </staff:when>
                <staff:otherwise>
                    <div class="row g-3 mb-4" id="employeeWorkCharts">
                        <div class="col-12 col-xl-5">
                            <section class="card stat-card shadow-sm p-3 p-md-4 h-100" aria-labelledby="statusChartTitle">
                                <h5 id="statusChartTitle" class="fw-bold mb-1">Theo trạng thái</h5>
                                <p class="text-secondary small mb-3">${empty statisticsMonth ? 'Tất cả công việc theo trạng thái' : 'Việc đang mở theo ngày gửi và việc đã hoàn thành trong tháng '.concat(statisticsMonthLabel)}</p>
                                <div class="employee-chart mb-3" hidden>
                                    <canvas id="employeeStatusChart" aria-hidden="true"></canvas>
                                </div>
                                <ul class="list-unstyled d-flex flex-wrap justify-content-center gap-3 mb-0">
                                    <li data-status-count="${pending}" style="--key-color: #f1ad1d">
                                        <span class="employee-chart-key d-inline-block rounded-circle me-1" aria-hidden="true"></span>
                                        <span>Chờ xử lý</span> <strong class="ms-1">${pending}</strong>
                                    </li>
                                    <li data-status-count="${processing}" style="--key-color: #3775ed">
                                        <span class="employee-chart-key d-inline-block rounded-circle me-1" aria-hidden="true"></span>
                                        <span>Đang xử lý</span> <strong class="ms-1">${processing}</strong>
                                    </li>
                                    <li data-status-count="${done}" style="--key-color: #198754">
                                        <span class="employee-chart-key d-inline-block rounded-circle me-1" aria-hidden="true"></span>
                                        <span>${empty statisticsMonth ? 'Đã hoàn thành' : 'Đã hoàn thành trong tháng'}</span> <strong class="ms-1">${done}</strong>
                                    </li>
                                </ul>
                            </section>
                        </div>
                        <div class="col-12 col-xl-7">
                            <section class="card stat-card shadow-sm p-3 p-md-4 h-100" aria-labelledby="priorityChartTitle">
                                <h5 id="priorityChartTitle" class="fw-bold mb-1">Theo mức độ</h5>
                                <p class="text-secondary small mb-3">Sự cố đang mở${empty statisticsMonth ? '' : ' được gửi trong tháng '.concat(statisticsMonthLabel)}</p>
                                <div class="employee-chart mb-3" hidden>
                                    <canvas id="employeePriorityChart" aria-hidden="true"></canvas>
                                </div>
                                <ul class="list-unstyled d-flex flex-wrap justify-content-center gap-3 mb-0">
                                    <staff:forEach var="item" items="${openByPriority}">
                                        <li data-priority-count="${item.value}" style="--key-color: ${item.key == 'Khẩn cấp' ? '#dc5061' : item.key == 'Trung bình' ? '#d7931a' : item.key == 'Thấp' ? '#3775ed' : '#64748b'}">
                                            <span class="employee-chart-key d-inline-block rounded-circle me-1" aria-hidden="true"></span>
                                            <span><staff:out value="${item.key}"/></span> <strong class="ms-1">${item.value}</strong>
                                        </li>
                                    </staff:forEach>
                                </ul>
                            </section>
                        </div>
                    </div>
                </staff:otherwise>
            </staff:choose>
        </staff:if>

        <staff:if test="${teamView}">
            <section aria-labelledby="staffTeamHeading" class="mb-4">
                <div class="team-heading d-flex align-items-center gap-3 p-3 p-md-4 mb-3 rounded-4 text-white shadow-sm">
                    <span class="d-inline-flex align-items-center justify-content-center rounded-3 border border-light border-opacity-25 bg-white bg-opacity-10 p-3 flex-shrink-0">
                        <i class="fa-solid fa-users fs-5" aria-hidden="true"></i>
                    </span>
                    <div>
                        <h5 id="staffTeamHeading" class="fs-4 fw-bold mb-0">Đồng nghiệp cùng tổ</h5>
                        <staff:if test="${not empty staffTeam.name}">
                            <p class="team-heading-name small mb-0 mt-1"><staff:out value="${staffTeam.name}"/></p>
                        </staff:if>
                    </div>
                </div>
                <div class="card team-table-card border-0 shadow-sm rounded-4 overflow-hidden">
                    <staff:choose>
                        <staff:when test="${staffTeamError}"><p class="p-4 mb-0 text-secondary">Không tải được thông tin tổ chuyên môn.</p></staff:when>
                        <staff:when test="${empty staffTeam.name}"><p class="p-4 mb-0 text-secondary">Bạn chưa được phân tổ.</p></staff:when>
                        <staff:when test="${empty staffTeam.members}"><p class="p-4 mb-0 text-secondary">Chưa có đồng nghiệp cùng tổ.</p></staff:when>
                        <staff:otherwise>
                            <div class="table-responsive">
                                <table class="table table-hover align-middle mb-0" aria-labelledby="staffTeamHeading">
                                    <thead class="table-light small text-uppercase">
                                        <tr>
                                            <th scope="col" class="ps-3 ps-md-4 py-3">Họ và tên</th>
                                            <th scope="col" class="pe-3 pe-md-4 py-3">Số điện thoại</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <staff:forEach var="member" items="${staffTeam.members}">
                                            <tr>
                                                <td class="ps-3 ps-md-4 py-3">
                                                    <div class="d-flex align-items-center gap-2 gap-md-3">
                                                        <span class="d-inline-flex rounded-circle p-2 bg-primary bg-opacity-10 text-primary flex-shrink-0">
                                                            <i class="fa-solid fa-user" aria-hidden="true"></i>
                                                        </span>
                                                        <span class="fw-semibold text-break"><staff:out value="${member.name}"/></span>
                                                    </div>
                                                </td>
                                                <td class="pe-3 pe-md-4 py-3">
                                                    <staff:choose>
                                                        <staff:when test="${not empty member.phone}">
                                                            <span class="text-nowrap">
                                                                <i class="fa-solid fa-phone text-success small me-2" aria-hidden="true"></i><staff:out value="${member.phone}"/>
                                                            </span>
                                                        </staff:when>
                                                        <staff:otherwise><span class="text-secondary small">Chưa có số điện thoại</span></staff:otherwise>
                                                    </staff:choose>
                                                </td>
                                            </tr>
                                        </staff:forEach>
                                    </tbody>
                                </table>
                            </div>
                        </staff:otherwise>
                    </staff:choose>
                </div>
            </section>
        </staff:if>


        <% List<SuCo> listSuCo = (List<SuCo>) request.getAttribute("listSuCo"); %>
        <staff:if test="${not teamView and not statisticsView}">
        <!-- BẢNG CÔNG VIỆC CẦN XỬ LÝ NGAY -->
        <div class="d-flex flex-wrap align-items-center gap-2 mb-3">
            <h5 id="work-list" tabindex="-1" class="fw-bold mb-0 ${not empty workFilter ? 'fs-3 d-flex align-items-center gap-2' : ''}">
                <staff:if test="${not empty workFilter}">
                    <span class="d-inline-flex rounded-3 p-2 ${workFilter == 'pending' ? 'bg-warning-subtle text-warning-emphasis' : 'bg-primary-subtle text-primary'}" aria-hidden="true">
                        <i class="fa-solid ${workFilter == 'pending' ? 'fa-clipboard-list' : 'fa-person-digging'} fs-5"></i>
                    </span>
                </staff:if>
                ${empty workListTitle ? 'Danh sách việc cần làm' : workListTitle}
            </h5>
            <div class="position-relative work-search ms-auto">
                <i class="fa-solid fa-magnifying-glass position-absolute top-50 start-0 translate-middle-y ms-3 text-primary pe-none" aria-hidden="true"></i>
                <input type="search" id="incidentSearch" class="form-control rounded-pill ps-5 pe-3 shadow-sm"
                       aria-label="Tìm theo mã sự cố, tiêu đề hoặc phòng" placeholder="Tìm theo mã, tiêu đề, phòng...">
            </div>
            <div class="position-relative">
                <label for="incidentDate" class="position-absolute top-50 start-0 translate-middle-y ms-3 text-primary mb-0 pe-none" title="Lọc theo ngày gửi"><i class="fa-regular fa-calendar" aria-hidden="true"></i><span class="visually-hidden">Lọc theo ngày gửi</span></label>
                <input type="date" id="incidentDate" class="form-control w-auto rounded-pill ps-5 pe-3 shadow-sm">
            </div>
            <select id="incidentPriority" class="form-select w-auto rounded-pill shadow-sm" aria-label="Lọc theo mức độ">
                <option value="">Tất cả mức độ</option>
                <option value="THẤP">Thấp</option>
                <option value="TRUNG BÌNH">Trung bình</option>
                <option value="KHẨN CẤP">Khẩn cấp</option>
            </select>
        </div>

        <div id="employeeWorkFeedback" class="mb-3" hidden>
            <span id="employeeWorkStatus" role="status"></span>
            <button type="button" id="retryEmployeeWorkRefresh" class="btn btn-sm btn-outline-primary" hidden>Tải lại danh sách</button>
        </div>
        <div id="employeeWorkTable" class="card stat-card border-0 shadow-sm rounded-3 mb-4">
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
                            <th class="fw-medium py-3">TRẠNG THÁI</th>
                            <th class="fw-medium py-3 text-center">CHI TIẾT</th>
                            <th class="pe-4 fw-medium py-3 text-center">THAO TÁC</th>
                        </tr>
                        </thead>
                        <tbody>
                        <%
                            // Hứng danh sách từ Servlet gửi sang

                            if (listSuCo != null && !listSuCo.isEmpty()) {
                                // Bắt đầu vòng lặp for
                                for (SuCo task : listSuCo) {
                                    String badgeMucDo = task.getMucDo().equals("KHẨN CẤP") ? "danger" : (task.getMucDo().equals("TRUNG BÌNH") ? "warning" : "success");
                                    String badgeTrangThai = task.getTrangThai().equals("Chờ xử lý") ? "warning" : (task.getTrangThai().equals("Đang xử lý") ? "primary" : "success");
                        %>
                        <% pageContext.setAttribute("workIssue", task); %>
                        <tr class="incident-row" data-report-date="<%= task.getNgayGui() == null ? "" : task.getNgayGui().toLocalDateTime().toLocalDate() %>" data-mucdo="${staffFn:escapeXml(workIssue.mucDo)}">
                            <td class="ps-4"><span class="fw-bold text-secondary">#SC0<%= task.getSuCoId() %></span></td>
                            <td>
                                <div class="fw-bold text-dark">${staffFn:escapeXml(workIssue.tieuDe)}</div>
                                <div class="text-muted" style="font-size: 0.8rem;">Gửi lúc: <%= task.getNgayGui() %></div>
                            </td>
                            <td><span class="fw-medium text-dark"><i class="fa-solid fa-location-dot text-danger me-1"></i> ${staffFn:escapeXml(workIssue.viTriPhong)}</span></td>
                            <td><span class="badge bg-<%= badgeMucDo %> bg-opacity-10 text-<%= badgeMucDo %> border border-<%= badgeMucDo %>">${staffFn:escapeXml(workIssue.mucDo)}</span></td>
                            <td>
                                <a href="tel:${staffFn:escapeXml(staffFn:replace(workIssue.soDienThoai, '.', ''))}" class="text-decoration-none fw-medium text-primary">
                                    <i class="fa-solid fa-phone fa-sm me-1"></i> ${staffFn:escapeXml(workIssue.soDienThoai)}
                                </a>
                            </td>
                            <td><span class="badge bg-<%= badgeTrangThai %> <%= task.getTrangThai().equals("Chờ xử lý") ? "text-dark" : "text-white" %>"><%= task.getTrangThai() %></span></td>

                            <td class="text-center">
                                <button type="button" class="btn btn-sm btn-light text-primary border"
                                        data-bs-toggle="modal" data-bs-target="#detailModal<%= task.getSuCoId() %>" title="Xem chi tiết công việc">
                                    <i class="fa-solid fa-eye"></i>
                                </button>
                            </td>

                            <td class="pe-4 text-center">
                                <% if (task.getTrangThai().equals("Chờ xử lý")) { %>
                                <button type="button" class="btn btn-sm btn-success shadow-sm"
                                        data-suco-id="<%= task.getSuCoId() %>"
                                        data-trang-thai="Đang xử lý"
                                        data-title="Xác nhận nhận việc"
                                        data-btn-class="btn-success"
                                        data-btn-text="Nhận việc">
                                    <i class="fa-solid fa-hand-holding-hand me-1"></i> Nhận việc
                                </button>

                                <% } else if (task.getTrangThai().equals("Đang xử lý")) { %>
                                <button type="button" class="btn btn-sm btn-primary shadow-sm"
                                        data-suco-id="<%= task.getSuCoId() %>"
                                        data-trang-thai="Đã hoàn thành"
                                        data-title="Xác nhận hoàn thành"
                                        data-btn-class="btn-primary"
                                        data-btn-text="Xác nhận xong">
                                    <i class="fa-solid fa-check me-1"></i> Xong
                                </button>
                                <% } else { %>
                                <span class="text-success fw-bold"><i class="fa-solid fa-check-double"></i></span>
                                <% } %>
                            </td>
                        </tr>
                        <%
                            } // Kết thúc dấu đóng ngoặc nhọn của vòng lặp for ở đây
                        } else {
                        %>
                        <tr>
                            <td colspan="8" class="text-center py-4 text-muted">Không có sự cố trong danh sách này.</td>
                        </tr>
                        <% } %>
                    <tr id="noIncidentMatches" hidden>
                        <td colspan="8" class="text-center py-4 text-muted">Không có sự cố phù hợp với bộ lọc.</td>
                    </tr>
                </tbody>
                    </table>
                </div>
                <div class="incident-pagination--employee">
                    <%@ include file="/WEB-INF/incident_pagination.jspf" %>
                </div>
            </div>
        </div>
        </staff:if>
    </div> <!-- End container-fluid -->
</div> <!-- End main-content -->

<!-- MODAL XÁC NHẬN THAO TÁC CHUNG -->
<div class="modal fade" id="confirmActionModal" tabindex="-1" aria-labelledby="confirmModalTitle" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header bg-primary text-white">
                <h5 class="modal-title fw-bold" id="confirmModalTitle"><i class="fa-solid fa-triangle-exclamation me-2" aria-hidden="true"></i><span id="confirmActionTitle">Xác nhận</span></h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body p-4">
                <p id="confirmModalMessage" class="fs-6 text-dark mb-0 fw-medium">Bạn có chắc chắn muốn thực hiện hành động này?</p>
                <div id="confirmActionError" class="text-danger mt-3" role="alert" hidden></div>
                <div id="repairNoteField" class="mt-3" hidden>
                    <label for="repairNote" class="form-label">Kết quả sửa chữa và vật tư thay thế</label>
                    <textarea id="repairNote" name="ghiChuKyThuat" form="confirmActionForm"
                              class="form-control" rows="4" maxlength="2000" disabled></textarea>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-light border px-4" data-bs-dismiss="modal">Hủy bỏ</button>
                <!-- Form gửi dữ liệu ngầm lên UpdateStatusServlet -->
                <form id="confirmActionForm" action="${pageContext.request.contextPath}/update-status" method="post" style="display:inline;">
                    <input type="hidden" name="workFilter" value="${workFilter}">
                    <input type="hidden" id="modalSuCoId" name="suCoId" value="">
                    <input type="hidden" id="modalTrangThaiMoi" name="trangThaiMoi" value="">
                    <button type="submit" id="confirmModalSubmitBtn" class="btn btn-primary px-4 fw-bold">Đồng ý</button>
                </form>
            </div>
        </div>
    </div>
</div>

<%@ include file="/WEB-INF/employee_account_modals.jspf" %>
<%@ include file="/WEB-INF/employee_maintenance_notice.jspf" %>

<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/js/incident-pagination.js"></script>

<!-- VÒNG LẶP TẠO MODAL CHI TIẾT SỰ CỐ CHO TỪNG DÒNG -->
<div id="employeeWorkDetails">
<%
    if (listSuCo != null && !listSuCo.isEmpty()) {
        for (SuCo task : listSuCo) {
            pageContext.setAttribute("workIssue", task);
            String badgeMucDo = "KHẨN CẤP".equals(task.getMucDo()) ? "danger" : ("TRUNG BÌNH".equals(task.getMucDo()) ? "warning" : "success");
            String badgeTrangThai = "Chờ xử lý".equals(task.getTrangThai()) ? "warning" : ("Đang xử lý".equals(task.getTrangThai()) ? "primary" : "success");
%>
<div class="modal fade" id="detailModal<%= task.getSuCoId() %>" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header bg-primary text-white">
                <h5 class="modal-title fw-bold"><i class="fa-solid fa-circle-info me-2"></i>Chi tiết sự cố #SC0<%= task.getSuCoId() %></h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body p-4 text-start">
                <h6 class="fw-bold text-primary mb-3">${staffFn:escapeXml(workIssue.tieuDe)}</h6>
                <div class="mb-2"><strong>Vị trí phòng:</strong> <span class="text-danger">${staffFn:escapeXml(workIssue.viTriPhong)}</span></div>
                <div class="mb-2"><strong>Mức độ:</strong> <span class="badge bg-<%= badgeMucDo %>">${staffFn:escapeXml(workIssue.mucDo)}</span></div>
                <div class="mb-2"><strong>Trạng thái:</strong> <span class="badge bg-<%= badgeTrangThai %>"><%= task.getTrangThai() %></span></div>
                <div class="mb-2"><strong>SĐT Sinh viên:</strong> <a href="tel:${staffFn:escapeXml(workIssue.soDienThoai)}" class="text-decoration-none fw-bold">${staffFn:escapeXml(workIssue.soDienThoai)}</a></div>
                <div class="mb-2"><strong>Ngày báo cáo:</strong> <%= task.getNgayGui() %></div>
                <hr>
                <div class="mb-1 fw-bold text-dark">Mô tả chi tiết từ sinh viên:</div>
                <div class="p-3 bg-light rounded border text-muted" style="font-size: 0.95rem;">
                    ${staffFn:escapeXml(workIssue.moTa)}
                </div>
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
</div>
<script src="${pageContext.request.contextPath}/js/employee-work-actions.js"></script>
<%@ include file="/WEB-INF/employee_sidebar_script.jspf" %>
<staff:if test="${statisticsView and pending + processing + done > 0}">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script>
        if (typeof Chart !== 'undefined') {
            const chartPanel = document.getElementById('employeeWorkCharts');

            function createEmployeeChart(canvasId, countAttribute, type, options) {
                const rows = Array.from(chartPanel.querySelectorAll('[' + countAttribute + ']'));
                const canvas = document.getElementById(canvasId);
                canvas.parentElement.hidden = false;
                new Chart(canvas, {
                    type,
                    data: {
                        labels: rows.map(row => row.querySelector('span:nth-child(2)').textContent.trim()),
                        datasets: [{
                            label: 'Sự cố',
                            data: rows.map(row => Number(row.getAttribute(countAttribute))),
                            backgroundColor: rows.map(row => row.style.getPropertyValue('--key-color').trim()),
                            borderColor: '#fff',
                            borderWidth: type === 'pie' ? 3 : 0,
                            borderRadius: type === 'bar' ? 7 : 0,
                            maxBarThickness: 64
                        }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        plugins: { legend: { display: false }, ...options.plugins },
                        scales: options.scales
                    }
                });
            }

            createEmployeeChart('employeeStatusChart', 'data-status-count', 'pie', {
                plugins: {
                    tooltip: {
                        callbacks: {
                            label(context) {
                                const values = context.dataset.data;
                                const total = values.reduce((sum, value) => sum + value, 0);
                                const share = new Intl.NumberFormat('vi-VN', { style: 'percent', maximumFractionDigits: 1 });
                                return context.label + ': ' + context.parsed + ' sự cố (' + share.format(context.parsed / total) + ')';
                            }
                        }
                    }
                }
            });
            createEmployeeChart('employeePriorityChart', 'data-priority-count', 'bar', {
                scales: {
                    x: { grid: { display: false }, ticks: { autoSkip: false } },
                    y: { beginAtZero: true, ticks: { precision: 0 }, grid: { color: '#e9eef5' } }
                }
            });
        }
    </script>
</staff:if>
<script src="${pageContext.request.contextPath}/js/form-validation.js"></script>
</body>
</html>