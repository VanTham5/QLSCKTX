<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Trang Sinh Viên - KTX Support</title>
    <!-- Bootstrap 5 -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- FontAwesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        body {
            background-color: #f0f2f5;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            overflow-x: hidden;
        }
        /* Sidebar Styles */
        .sidebar {
            width: 260px;
            background-color: #ffffff;
            height: 100vh;
            position: fixed;
            left: 0;
            top: 0;
            border-right: 1px solid #e0e0e0; /* Dùng border thay cho shadow để trông phẳng và liền mạch hơn */
            z-index: 1000;
        }
        .main-content {
            margin-left: 260px;
            min-height: 100vh;
            padding-bottom: 30px;
        }
        .sidebar .nav-link {
            color: #4b5563;
            padding: 12px 20px;
            font-weight: 500;
            border-left: 3px solid transparent;
        }
        .sidebar .nav-link:hover, .sidebar .nav-link.active {
            background-color: #f3f4f6;
            color: #0d6efd;
            border-left: 3px solid #0d6efd;
        }
        .sidebar-heading {
            font-size: 0.75rem;
            text-transform: uppercase;
            color: #9ca3af;
            font-weight: bold;
            padding: 10px 20px;
            margin-top: 15px;
        }
        /* Căn lề icon menu */
        .w-20px {
            width: 22px;
            text-align: center;
        }
        /* Top Header */
        .top-header {
            background-color: #ffffff;
            height: 60px;
            border-bottom: 1px solid #e0e0e0; /* Đường viền dưới liền mạch với sidebar */
            display: flex;
            justify-content: flex-end;
            align-items: center;
            padding: 0 30px;
        }
        /* Hero Banner Gradient */
        .hero-banner {
            background: linear-gradient(135deg, #1e3c72 0%, #2a5298 50%, #20c997 100%);
            border-radius: 15px;
            color: white;
            padding: 30px;
            margin-top: 20px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
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
    </style>
</head>
<body>

<!-- SIDEBAR -->
<div class="sidebar d-flex flex-column" style="overflow-y: auto;">
    <!-- Thêm border-bottom đồng nhất với top-header để tạo cảm giác liền mạch -->
    <div class="d-flex align-items-center p-3" style="height: 60px; border-bottom: 1px solid #e0e0e0;">
        <i class="fa-solid fa-building-shield fs-4 text-warning me-2"></i>
        <h5 class="mb-0 fw-bold text-dark" style="font-size: 1.1rem;">KTX - ĐHCNHN</h5>
    </div>

    <div class="sidebar-heading">Tổng quan</div>
    <a href="student_home.jsp" class="nav-link active"><i class="fa-solid fa-house me-2 w-20px"></i> Trang chủ</a>
    <a href="#" class="nav-link"><i class="fa-solid fa-bell me-2 w-20px"></i> Thông báo từ BQL</a>

    <div class="sidebar-heading">Dịch vụ KTX</div>
    <a href="#" class="nav-link"><i class="fa-solid fa-wrench me-2 w-20px"></i> Báo cáo sự cố</a>
    <a href="#" class="nav-link"><i class="fa-solid fa-list-check me-2 w-20px"></i> Lịch sử báo cáo</a>


    <div class="sidebar-heading">Trợ giúp & Liên hệ</div>
    <a href="#" class="nav-link"><i class="fa-solid fa-book me-2 w-20px"></i> Hướng dẫn & Nội quy</a>
    <a href="tel:0123456789" class="nav-link fw-bold text-success"><i class="fa-solid fa-phone-volume me-2 w-20px"></i> Hotline: 0123.456.789</a>

    <div class="sidebar-heading">Hồ sơ cá nhân</div>
    <a href="#" class="nav-link"><i class="fa-regular fa-user me-2 w-20px"></i> Thông tin cá nhân</a>
    <a href="#" class="nav-link"><i class="fa-solid fa-shield-halved me-2 w-20px"></i> Đổi mật khẩu</a>
    <a href="${pageContext.request.contextPath}/login.jsp" class="nav-link text-danger mt-3 mb-4"><i class="fa-solid fa-right-from-bracket me-2 w-20px"></i> Đăng xuất</a>
</div>

<!-- MAIN CONTENT -->
<div class="main-content">

    <!-- HEADER TOP -->
    <div class="top-header">
        <div class="dropdown">
            <a href="#" class="d-flex align-items-center text-decoration-none text-dark" data-bs-toggle="dropdown">
                <img src="https://ui-avatars.com/api/?name=${not empty sessionScope.acc ? sessionScope.acc.hoTen : 'SV'}&background=random" alt="Avatar" width="32" height="32" class="rounded-circle me-2">
                <span class="fw-bold">${not empty sessionScope.acc ? sessionScope.acc.hoTen : 'Đỗ Văn Thám'}</span>
                <i class="fa-solid fa-chevron-down ms-2" style="font-size: 12px;"></i>
            </a>
            <ul class="dropdown-menu dropdown-menu-end">
                <li><a class="dropdown-item" href="#">Hồ sơ</a></li>
                <li><hr class="dropdown-divider"></li>
                <li><a class="dropdown-item text-danger" href="${pageContext.request.contextPath}/login.jsp">Đăng xuất</a></li>
            </ul>
        </div>
    </div>

    <div class="container-fluid px-4">

        <!-- THÔNG BÁO QUAN TRỌNG TỪ BQL -->
        <div class="alert alert-warning alert-dismissible fade show border-0 shadow-sm rounded-3 mt-4 mb-3" role="alert" style="border-left: 5px solid #ffc107 !important;">
            <div class="d-flex align-items-center">
                <div class="bg-warning bg-opacity-25 p-3 rounded-circle me-3">
                    <i class="fa-solid fa-bullhorn fs-4 text-warning"></i>
                </div>
                <div>
                    <h6 class="alert-heading fw-bold mb-1 text-dark">Thông báo: Lịch cắt điện bảo trì Tòa A1</h6>
                    <p class="mb-0 text-muted" style="font-size: 0.85rem;">Ban quản lý KTX xin thông báo, tòa A1 sẽ tạm ngưng cung cấp điện từ 08:00 đến 11:30 ngày mai để bảo trì trạm biến áp. Đề nghị sinh viên chú ý sắp xếp.</p>
                </div>
            </div>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close" style="top: 10px;"></button>
        </div>

        <!-- NÚT BÁO CÁO SỰ CỐ -->
        <div class="d-flex justify-content-start mb-4">
            <button class="btn btn-primary fw-bold shadow-sm rounded-pill px-4 py-2">
                <i class="fa-solid fa-plus me-2"></i> Báo cáo sự cố
            </button>
        </div>

        <!-- THỐNG KÊ NHANH -->
        <div class="row g-4 mt-1">
            <div class="col-md-4">
                <div class="card stat-card h-100 p-3 d-flex flex-row align-items-center">
                    <div class="icon-box bg-primary bg-opacity-10 text-primary me-3">
                        <i class="fa-regular fa-bell"></i>
                    </div>
                    <div>
                        <h4 class="fw-bold mb-0">3</h4>
                        <span class="text-muted small">Thông báo mới</span>
                    </div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="card stat-card h-100 p-3 d-flex flex-row align-items-center">
                    <div class="icon-box bg-warning bg-opacity-10 text-warning me-3">
                        <i class="fa-solid fa-hourglass-half"></i>
                    </div>
                    <div>
                        <h4 class="fw-bold mb-0">1</h4>
                        <span class="text-muted small">Sự cố chờ xử lý</span>
                    </div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="card stat-card h-100 p-3 d-flex flex-row align-items-center">
                    <div class="icon-box bg-success bg-opacity-10 text-success me-3">
                        <i class="fa-solid fa-check-double"></i>
                    </div>
                    <div>
                        <h4 class="fw-bold mb-0">5</h4>
                        <span class="text-muted small">Sự cố đã hoàn thành</span>
                    </div>
                </div>
            </div>
        </div>

        <!-- BẢNG DANH SÁCH SỰ CỐ GẦN ĐÂY -->
        <div class="d-flex justify-content-between align-items-center mt-5 mb-3">
            <h5 class="fw-bold mb-0">Danh sách sự cố gần đây</h5>
            <a href="#" class="text-decoration-none text-primary fw-medium">Xem tất cả <i class="fa-solid fa-arrow-right fs-6 ms-1"></i></a>
        </div>

        <div class="card stat-card border-0 shadow-sm rounded-3 mb-4">
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0">
                        <thead class="table-light text-muted" style="font-size: 0.85rem;">
                        <tr>
                            <th class="ps-4 fw-medium py-3">MÃ SC</th>
                            <th class="fw-medium py-3">TIÊU ĐỀ SỰ CỐ</th>
                            <th class="fw-medium py-3">DANH MỤC</th>
                            <th class="fw-medium py-3">MỨC ĐỘ</th>
                            <th class="fw-medium py-3">NGÀY GỬI</th>
                            <th class="fw-medium py-3">TRẠNG THÁI</th>
                            <th class="pe-4 fw-medium py-3 text-center">THAO TÁC</th>
                        </tr>
                        </thead>
                        <tbody>
                        <%
                            // Mock data giả lập chờ kết nối Servlet
                            String[][] mockData = {
                                    {"#SC005", "Chập điện ổ cắm khu vực giường tầng", "Phòng 304 - Tòa A1", "Điện", "KHẨN CẤP", "30/10/2026", "Chờ xử lý", "danger", "warning"},
                                    {"#SC004", "Rò rỉ nước ở vòi bồn rửa mặt", "Phòng 304 - Tòa A1", "Nước", "TRUNG BÌNH", "28/10/2026", "Đang xử lý", "warning", "primary"},
                                    {"#SC003", "Quạt trần số 2 kêu to và rung lắc", "Phòng 304 - Tòa A1", "Cơ sở vật chất", "THẤP", "25/10/2026", "Đã hoàn thành", "success", "success"}
                            };

                            for (int i = 0; i < mockData.length; i++) {
                                String[] sc = mockData[i];
                        %>
                        <tr>
                            <td class="ps-4"><span class="fw-bold text-secondary"><%= sc[0] %></span></td>
                            <td>
                                <div class="fw-bold text-dark"><%= sc[1] %></div>
                                <div class="text-muted" style="font-size: 0.8rem;"><%= sc[2] %></div>
                            </td>
                            <td><span class="fw-medium text-secondary"><%= sc[3] %></span></td>
                            <td><span class="badge bg-<%= sc[7] %> bg-opacity-10 text-<%= sc[7] %> border border-<%= sc[7] %>"><%= sc[4] %></span></td>
                            <td class="text-muted"><%= sc[5] %></td>
                            <td><span class="badge bg-<%= sc[8] %> <%= sc[8].equals("warning") ? "text-dark" : "text-white" %>"><%= sc[6] %></span></td>
                            <td class="pe-4 text-center">
                                <button class="btn btn-sm btn-light text-primary border" title="Xem chi tiết">
                                    <i class="fa-solid fa-eye"></i>
                                </button>
                            </td>
                        </tr>
                        <%
                            }
                        %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

    </div> <!-- End container-fluid -->
</div> <!-- End main-content -->

<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>