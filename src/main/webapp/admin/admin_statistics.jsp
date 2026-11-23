<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="model.SuCo" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thống kê sự cố - KTX Support</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        body {
            background-color: #f8fafc;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            overflow-x: hidden;
            color: #1e293b;
        }
        /* Sidebar xanh đậm */
        .sidebar {
            width: 260px;
            background-color: #1e293b;
            height: 100vh;
            position: fixed;
            left: 0;
            top: 0;
            z-index: 1000;
        }
        .main-content {
            margin-left: 260px;
            min-height: 100vh;
            padding-bottom: 36px;
        }
        .sidebar .nav-link {
            color: #cbd5e1;
            padding: 12px 20px;
            font-weight: 500;
            border-left: 3px solid transparent;
            transition: all 0.15s ease;
        }
        .sidebar .nav-link:hover, .sidebar .nav-link.active {
            background-color: rgba(255,255,255,0.08);
            color: #ffffff;
            border-left: 3px solid #3b82f6;
        }
        .sidebar-heading {
            font-size: 0.72rem;
            text-transform: uppercase;
            color: #64748b;
            font-weight: 700;
            letter-spacing: 0.04em;
            padding: 10px 20px;
            margin-top: 14px;
        }
        .w-20px { width: 22px; text-align: center; }

        .top-header {
            background-color: #ffffff;
            height: 60px;
            border-bottom: 1px solid #e2e8f0;
            display: flex;
            justify-content: flex-end;
            align-items: center;
            padding: 0 30px;
            position: sticky;
            top: 0;
            z-index: 999;
        }
        .panel-card {
            background: #ffffff;
            border: 1px solid #e2e8f0;
            border-radius: 12px;
            box-shadow: 0 1px 3px rgba(15, 23, 42, 0.04);
        }
        .kpi-icon {
            width: 44px;
            height: 44px;
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.15rem;
        }
        .chart-wrapper {
            position: relative;
            height: 300px;
            width: 100%;
        }
        .filter-pill {
            border-radius: 8px;
            font-weight: 500;
        }
    </style>
</head>
<body>

<!-- SIDEBAR ADMIN -->
<div class="sidebar d-flex flex-column" style="overflow-y: auto;">
    <div class="d-flex align-items-center p-3 border-bottom border-secondary border-opacity-25" style="height: 60px;">
        <i class="fa-solid fa-server fs-4 text-primary me-2"></i>
        <h5 class="mb-0 fw-bold text-white" style="font-size: 1.05rem;">QUẢN TRỊ HỆ THỐNG</h5>
    </div>

    <div class="sidebar-heading">Tổng quan</div>
    <a href="${pageContext.request.contextPath}/admin-home" class="nav-link">
        <i class="fa-solid fa-chart-line me-2 w-20px"></i> Bảng điều khiển
    </a>

    <div class="sidebar-heading">Nghiệp vụ</div>
    <a href="${pageContext.request.contextPath}/admin-home" class="nav-link">
        <i class="fa-solid fa-bullhorn me-2 w-20px"></i> Đăng thông báo
    </a>
    <a href="${pageContext.request.contextPath}/admin-incidents" class="nav-link d-flex justify-content-between align-items-center">
        <span><i class="fa-solid fa-triangle-exclamation me-2 w-20px"></i> Quản lý sự cố</span>
        <span class="badge bg-danger rounded-pill">${pending != null ? pending : 0}</span>
    </a>
    <a href="${pageContext.request.contextPath}/admin-accounts" class="nav-link">
        <i class="fa-solid fa-users me-2 w-20px"></i> Quản lý tài khoản
    </a>
    <a href="${pageContext.request.contextPath}/admin-phong" class="nav-link">
        <i class="fa-solid fa-building me-2 w-20px"></i> Quản lý phòng/tòa
    </a>
    <a href="${pageContext.request.contextPath}/admin-loai-su-co" class="nav-link">
        <i class="fa-solid fa-list me-2 w-20px"></i> Danh mục loại sự cố
    </a>
    <a href="${pageContext.request.contextPath}/admin-statistics" class="nav-link active">
        <i class="fa-solid fa-chart-pie me-2 w-20px"></i> Thống kê
    </a>

    <div class="sidebar-heading">Hệ thống</div>
    <a href="#" class="nav-link"><i class="fa-solid fa-gear me-2 w-20px"></i> Cài đặt</a>
    <a href="${pageContext.request.contextPath}/logout" class="nav-link text-danger mt-3 mb-4">
        <i class="fa-solid fa-right-from-bracket me-2 w-20px"></i> Đăng xuất
    </a>
</div>

<!-- MAIN CONTENT -->
<div class="main-content">

    <!-- TOP HEADER -->
    <div class="top-header">
        <div class="dropdown">
            <a href="#" class="d-flex align-items-center text-decoration-none text-dark" data-bs-toggle="dropdown">
                <img src="https://ui-avatars.com/api/?name=${not empty sessionScope.acc ? sessionScope.acc.hoTen : 'Admin'}&background=1e293b&color=fff"
                     alt="Avatar" width="32" height="32" class="rounded-circle me-2">
                <span class="fw-semibold">${not empty sessionScope.acc ? sessionScope.acc.hoTen : 'Quản trị viên'}</span>
                <i class="fa-solid fa-chevron-down ms-2 text-muted" style="font-size: 12px;"></i>
            </a>
            <ul class="dropdown-menu dropdown-menu-end">
                <li><a class="dropdown-item" href="#">Cấu hình tài khoản</a></li>
                <li><hr class="dropdown-divider"></li>
                <li><a class="dropdown-item text-danger" href="${pageContext.request.contextPath}/logout">Đăng xuất</a></li>
            </ul>
        </div>
    </div>

    <div class="container-fluid px-4">

        <!-- TIÊU ĐỀ & BỘ LỌC THỜI GIAN -->
        <div class="d-flex flex-wrap justify-content-between align-items-end gap-3 mt-4 mb-4">
            <div>
                <h4 class="fw-bold mb-1">Thống kê tổng quan sự cố</h4>
                <p class="text-muted mb-0 small">Khoảng thời gian đang xem: <strong class="text-dark">${rangeLabel}</strong></p>
            </div>

            <div class="d-flex flex-wrap align-items-center gap-2">
                <a href="?range=this_month" class="btn btn-sm filter-pill ${range == 'this_month' ? 'btn-primary' : 'btn-white border'}">Tháng này</a>
                <a href="?range=last_month" class="btn btn-sm filter-pill ${range == 'last_month' ? 'btn-primary' : 'btn-white border'}">Tháng trước</a>
                <a href="?range=last_6_months" class="btn btn-sm filter-pill ${range == 'last_6_months' ? 'btn-primary' : 'btn-white border'}">6 tháng qua</a>
                <a href="?range=this_year" class="btn btn-sm filter-pill ${range == 'this_year' ? 'btn-primary' : 'btn-white border'}">Năm nay</a>

                <!-- Chọn khoảng thời gian bằng lịch -->
                <form method="get" action="${pageContext.request.contextPath}/admin-statistics"
                      class="d-flex align-items-center bg-white border rounded-3 px-2 py-1">
                    <input type="hidden" name="range" value="custom">
                    <input type="date" name="fromDate" value="${fromDate}"
                           class="form-control form-control-sm border-0 p-0 shadow-none"
                           style="width: 104px;" required>
                    <span class="text-muted small mx-2">–</span>
                    <input type="date" name="toDate" value="${toDate}"
                           class="form-control form-control-sm border-0 p-0 shadow-none"
                           style="width: 104px;" required>
                    <button type="submit" class="btn btn-sm btn-primary py-0 px-2 ms-2">Lọc</button>
                </form>
            </div>
        </div>

        <!-- 4 THẺ KPI TỔNG QUAN (KÈM % TĂNG/GIẢM) -->
        <div class="row g-3 mb-4">
            <div class="col-sm-6 col-xl-3">
                <div class="panel-card p-3 bg-primary bg-opacity-10 border-primary border-opacity-25">
                    <div class="d-flex justify-content-between align-items-start">
                        <div>
                            <div class="text-muted small fw-medium mb-1">Tổng số sự cố</div>
                            <h3 class="fw-bold mb-1">${totalSuCo}</h3>
                            <span class="small fw-medium ${totalChange >= 0 ? 'text-primary' : 'text-danger'}">
                                ${totalChange >= 0 ? '↑ +' : '↓ '}${totalChange}% <span class="text-muted fw-normal">so với kỳ trước</span>
                            </span>
                        </div>
                        <div class="kpi-icon bg-primary bg-opacity-10 text-primary">
                            <i class="fa-solid fa-layer-group"></i>
                        </div>
                    </div>
                </div>
            </div>

            <div class="col-sm-6 col-xl-3">
                <div class="panel-card p-3 bg-success bg-opacity-10 border-success border-opacity-25">
                    <div class="d-flex justify-content-between align-items-start">
                        <div>
                            <div class="text-muted small fw-medium mb-1">Đã hoàn thành</div>
                            <h3 class="fw-bold mb-1 text-success">${completedCount}</h3>
                            <span class="small fw-medium ${completedChange >= 0 ? 'text-success' : 'text-danger'}">
                                ${completedChange >= 0 ? '↑ +' : '↓ '}${completedChange}% <span class="text-muted fw-normal">so với kỳ trước</span>
                            </span>
                        </div>
                        <div class="kpi-icon bg-success bg-opacity-10 text-success">
                            <i class="fa-solid fa-circle-check"></i>
                        </div>
                    </div>
                </div>
            </div>

            <div class="col-sm-6 col-xl-3">
                <div class="panel-card p-3 bg-warning bg-opacity-10 border-warning border-opacity-25">
                    <div class="d-flex justify-content-between align-items-start">
                        <div>
                            <div class="text-muted small fw-medium mb-1">Đang xử lý</div>
                            <h3 class="fw-bold mb-1 text-primary">${processingCount}</h3>
                            <span class="small fw-medium ${processingChange >= 0 ? 'text-warning' : 'text-success'}">
                                ${processingChange >= 0 ? '↑ +' : '↓ '}${processingChange}% <span class="text-muted fw-normal">so với kỳ trước</span>
                            </span>
                        </div>
                        <div class="kpi-icon bg-warning bg-opacity-10 text-warning">
                            <i class="fa-solid fa-screwdriver-wrench"></i>
                        </div>
                    </div>
                </div>
            </div>

            <div class="col-sm-6 col-xl-3">
                <div class="panel-card p-3 bg-danger bg-opacity-10 border-danger border-opacity-25">
                    <div class="d-flex justify-content-between align-items-start">
                        <div>
                            <div class="text-muted small fw-medium mb-1">Chờ xử lý</div>
                            <h3 class="fw-bold mb-1 text-danger">${pendingCount}</h3>
                            <span class="small fw-medium ${pendingChange <= 0 ? 'text-success' : 'text-danger'}">
                                ${pendingChange >= 0 ? '↑ +' : '↓ '}${pendingChange}% <span class="text-muted fw-normal">so với kỳ trước</span>
                            </span>
                        </div>
                        <div class="kpi-icon bg-danger bg-opacity-10 text-danger">
                            <i class="fa-solid fa-hourglass-half"></i>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- 2 BIỂU ĐỒ CHÍNH -->
        <div class="row g-3 mb-4">
            <div class="col-lg-7">
                <div class="panel-card p-4 h-100">
                    <h6 class="fw-bold mb-1">Số lượng sự cố theo loại</h6>
                    <p class="text-muted small mb-3">Mỗi nhóm sự cố được phân biệt bằng màu riêng</p>
                    <div class="chart-wrapper">
                        <canvas id="loaiSuCoChart"></canvas>
                    </div>
                </div>
            </div>

            <div class="col-lg-5">
                <div class="panel-card p-4 h-100">
                    <h6 class="fw-bold mb-1">Trạng thái xử lý sự cố</h6>
                    <p class="text-muted small mb-3">Hiển thị số lượng và tỷ lệ phần trăm</p>
                    <div class="chart-wrapper">
                        <canvas id="trangThaiChart"></canvas>
                    </div>
                </div>
            </div>
        </div>

        <!-- DANH SÁCH SỰ CỐ GẦN ĐÂY & NHẬN XÉT NHANH -->
        <div class="row g-3">
            <div class="col-lg-8">
                <div class="panel-card p-4 h-100">
                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <h6 class="fw-bold mb-0">Danh sách sự cố gần đây</h6>
                        <a href="${pageContext.request.contextPath}/admin-incidents" class="text-decoration-none small fw-semibold">
                            Xem tất cả <i class="fa-solid fa-arrow-right ms-1"></i>
                        </a>
                    </div>
                    <div class="table-responsive">
                        <table class="table table-sm table-hover align-middle mb-0">
                            <thead class="table-light text-muted small">
                            <tr>
                                <th>#</th>
                                <th>Loại sự cố</th>
                                <th>Mô tả</th>
                                <th>Thời gian báo cáo</th>
                                <th>Trạng thái</th>
                                <th class="text-center">Thao tác</th>
                            </tr>
                            </thead>
                            <tbody class="small">
                            <%
                                List<SuCo> recentList = (List<SuCo>) request.getAttribute("recentList");
                                if (recentList != null && !recentList.isEmpty()) {
                                    int stt = 1;
                                    for (SuCo sc : recentList) {
                                        String st = sc.getTrangThai() != null ? sc.getTrangThai() : "";
                                        String badge = ("Đã hoàn thành".equals(st) || "Hoàn thành".equals(st))
                                                ? "bg-success text-white"
                                                : ("Đang xử lý".equals(st) ? "bg-primary text-white" : "bg-warning text-dark");
                            %>
                            <tr>
                                <td><%= stt++ %></td>
                                <td><span class="badge bg-light text-dark border"><%= sc.getTenLoaiSuCo() %></span></td>
                                <td class="fw-medium text-dark"><%= sc.getTieuDe() %></td>
                                <td class="text-muted"><%= sc.getNgayGui() %></td>
                                <td><span class="badge <%= badge %>"><%= st %></span></td>
                                <td class="text-center">
                                    <button type="button" class="btn btn-sm btn-light text-primary border"
                                            data-bs-toggle="modal" data-bs-target="#statDetailModal<%= sc.getSuCoId() %>"
                                            title="Xem chi tiết">
                                        <i class="fa-solid fa-eye"></i>
                                    </button>
                                </td>
                            </tr>
                            <%
                                }
                            } else {
                            %>
                            <tr>
                                <td colspan="6" class="text-center text-muted py-4">Không có sự cố nào trong khoảng thời gian này.</td>
                            </tr>
                            <% } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <div class="col-lg-4">
                <div class="panel-card p-4 h-100">
                    <h6 class="fw-bold mb-3">
                        <i class="fa-regular fa-lightbulb text-primary me-1"></i> Nhận xét nhanh
                    </h6>
                    <div class="small text-secondary d-flex flex-column gap-2">
                        <p class="mb-0">
                            • Trong <strong class="text-dark">${rangeLabel}</strong>, hệ thống ghi nhận
                            <strong class="text-dark">${totalSuCo}</strong> sự cố
                            (${totalChange >= 0 ? 'tăng ' : 'giảm '}${totalChange >= 0 ? totalChange : -totalChange}% so với kỳ trước).
                        </p>
                        <p class="mb-0">
                            • Nhóm phát sinh nhiều nhất là <strong class="text-dark">${topLoai}</strong> (${maxLoaiCount} sự cố).
                        </p>
                        <p class="mb-0">
                            • Tỷ lệ xử lý hoàn thành đạt <strong class="text-success">${completionRate}%</strong>;
                            hiện còn <strong class="text-danger">${pendingCount}</strong> sự cố đang chờ xử lý.
                        </p>
                    </div>
                </div>
            </div>
        </div>

    </div>
</div>

<!-- MODAL XEM CHI TIẾT SỰ CỐ -->
<%
    if (recentList != null && !recentList.isEmpty()) {
        for (SuCo sc : recentList) {
%>
<div class="modal fade" id="statDetailModal<%= sc.getSuCoId() %>" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header bg-dark text-white">
                <h6 class="modal-title fw-bold">Chi tiết sự cố #SC0<%= sc.getSuCoId() %></h6>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body small">
                <div class="mb-2"><strong>Tiêu đề:</strong> <%= sc.getTieuDe() %></div>
                <div class="mb-2"><strong>Loại sự cố:</strong> <%= sc.getTenLoaiSuCo() %></div>
                <div class="mb-2"><strong>Người báo cáo:</strong> <%= sc.getTenNguoiGui() %> (<%= sc.getSoDienThoai() %>)</div>
                <div class="mb-2"><strong>Vị trí:</strong> <%= sc.getViTriPhong() %></div>
                <div class="mb-2"><strong>Trạng thái:</strong> <%= sc.getTrangThai() %></div>
                <div class="mb-2"><strong>Thời gian báo cáo:</strong> <%= sc.getNgayGui() %></div>
                <div class="mb-2">
                    <strong>Nhân viên phụ trách:</strong>
                    <%
                        String trangThaiNV = sc.getTrangThai();
                        String tenNV = sc.getTenNhanVien();
                        String sdtNV = sc.getSdtNhanVien();
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
                <div class="fw-bold mb-1">Mô tả chi tiết:</div>
                <div class="p-2 bg-light rounded border text-muted">
                    <%= sc.getMoTa() != null ? sc.getMoTa() : "Không có mô tả chi tiết." %>
                </div>
                <%
                    String repairNote = sc.getGhiChuKyThuat();
                    if (repairNote != null && !repairNote.trim().isEmpty()) {
                %>
                <div class="mt-3 mb-1 fw-bold">Kết quả sửa chữa và vật tư thay thế</div>
                <div class="p-3 bg-light rounded border text-break" style="white-space: pre-wrap"><%= repairNote %></div>
                <%
                    }
                %>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-sm btn-secondary" data-bs-dismiss="modal">Đóng</button>
            </div>
        </div>
    </div>
</div>
<%
        }
    }
%>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script>
    const loaiLabels = JSON.parse('${not empty loaiLabelsJson ? loaiLabelsJson : "[]"}');
    const loaiValues = JSON.parse('${not empty loaiValuesJson ? loaiValuesJson : "[]"}');

    const trangThaiLabels = JSON.parse('${not empty trangThaiLabelsJson ? trangThaiLabelsJson : "[]"}');
    const trangThaiValues = JSON.parse('${not empty trangThaiValuesJson ? trangThaiValuesJson : "[]"}');

    // Gán màu cố định theo từng loại sự cố
    function getLoaiColor(label) {
        const text = (label || '').toLowerCase();
        if (text.includes('cơ sở') || text.includes('vật chất')) return '#f59e0b'; // Cam
        if (text.includes('điện')) return '#3b82f6';                               // Xanh dương
        if (text.includes('nước') || text.includes('vệ sinh')) return '#22c55e';  // Xanh lá
        if (text.includes('an ninh') || text.includes('trật tự')) return '#a855f7'; // Tím
        if (text.includes('mạng') || text.includes('internet')) return '#f05252';  // Đỏ
        return '#06b6d4'; // Màu phụ nếu có loại khác
    }

    const loaiColors = loaiLabels.map(getLoaiColor);

    new Chart(document.getElementById('loaiSuCoChart'), {
        type: 'bar',
        data: {
            labels: loaiLabels,
            datasets: [{
                label: 'Số lượng sự cố',
                data: loaiValues,
                backgroundColor: loaiColors,
                borderRadius: 6,
                maxBarThickness: 44
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: { legend: { display: false } },
            scales: {
                y: {
                    beginAtZero: true,
                    ticks: { stepSize: 1, precision: 0 }
                }
            }
        }
    });

    // Tính tổng để hiển thị số lượng + phần trăm trên biểu đồ Donut
    const totalStatus = trangThaiValues.reduce((sum, v) => sum + v, 0);
    const trangThaiDisplayLabels = trangThaiLabels.map((lbl, idx) => {
        const val = trangThaiValues[idx] || 0;
        const pct = totalStatus > 0 ? ((val * 100) / totalStatus).toFixed(1) : '0.0';
        return lbl + ': ' + val + ' (' + pct + '%)';
    });

    const statusColors = trangThaiLabels.map(lbl => {
        const t = (lbl || '').toLowerCase();
        if (t.includes('hoàn thành')) return '#16a34a';
        if (t.includes('đang xử lý')) return '#2563eb';
        if (t.includes('chờ xử lý')) return '#f59e0b';
        return '#dc2626';
    });

    new Chart(document.getElementById('trangThaiChart'), {
        type: 'doughnut',
        data: {
            labels: trangThaiDisplayLabels,
            datasets: [{
                data: trangThaiValues,
                backgroundColor: statusColors,
                borderWidth: 2
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            cutout: '62%',
            plugins: {
                legend: { position: 'bottom' },
                tooltip: {
                    callbacks: {
                        label: function(ctx) {
                            const val = ctx.parsed || 0;
                            const pct = totalStatus > 0 ? ((val * 100) / totalStatus).toFixed(1) : '0.0';
                            return ' ' + val + ' sự cố (' + pct + '%)';
                        }
                    }
                }
            }
        }
    });
</script>
</body>
</html>