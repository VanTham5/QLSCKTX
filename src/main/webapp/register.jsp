<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đăng ký tài khoản - KTX Support</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        body {
            background-color: #f0f2f5;
            height: 100vh;
            display: flex;
            align-items: center;
        }
        .register-card {
            border: none;
            border-radius: 15px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.08);
            overflow: hidden;
        }
        .bg-login-image {
            background-image: url('https://images.unsplash.com/photo-1522202176988-66273c2fd55f?q=80&w=2071&auto=format&fit=crop');
            background-position: center;
            background-size: cover;
        }
    </style>
</head>
<body>

<div class="container">
    <div class="row justify-content-center">
        <div class="col-xl-10 col-lg-12 col-md-9">
            <div class="card register-card">
                <div class="card-body p-0">
                    <div class="row">
                        <!-- Hình ảnh trang trí bên trái -->
                        <div class="col-lg-6 d-none d-lg-block bg-login-image"></div>

                        <!-- Form Đăng ký bên phải -->
                        <div class="col-lg-6">
                            <div class="p-5">
                                <div class="text-center mb-4">
                                    <h4 class="fw-bold text-dark"><i class="fa-solid fa-user-plus text-primary me-2"></i>Tạo tài khoản KTX</h4>
                                </div>

                                <!-- Hiển thị thông báo lỗi từ Servlet -->
                                <% if (request.getAttribute("error") != null) { %>
                                <div class="alert alert-danger p-2 text-center" role="alert">
                                    <i class="fa-solid fa-triangle-exclamation"></i> <%= request.getAttribute("error") %>
                                </div>
                                <% } %>

                                <form action="${pageContext.request.contextPath}/register" method="POST" class="needs-validation" novalidate>

                                    <div class="mb-3">
                                        <label class="form-label fw-bold small text-muted">Họ và Tên</label>
                                        <input type="text" class="form-control" name="fullName" placeholder="Nhập họ và tên..." value="${oldFullName}" required>
                                        <div class="invalid-feedback">Vui lòng nhập họ tên.</div>
                                    </div>

                                    <div class="mb-3">
                                        <label class="form-label fw-bold small text-muted">Tên đăng nhập </label>
                                        <input type="text" class="form-control" name="username" placeholder="VD: SV2021001" value="${oldUsername}" required>
                                        <div class="invalid-feedback">Vui lòng nhập tên đăng nhập.</div>
                                    </div>

                                    <div class="mb-3 mt-3">
                                        <label class="form-label fw-bold small text-muted">Chọn Tòa nhà & Phòng <span class="text-danger">*</span></label>
                                        <select class="form-select" name="phongId" required>
                                            <option value="" selected disabled>-- Vui lòng chọn phòng --</option>
                                            <!-- Thay đổi value ở đây cho khớp với phong_id trong bảng phong của cơ sở dữ liệu -->
                                            <optgroup label="Tòa A1 (Nam)">
                                                <option value="1">Phòng 101 - Tòa A1</option>
                                                <option value="2">Phòng 102 - Tòa A1</option>
                                                <option value="3">Phòng 103 - Tòa A1</option>
                                            </optgroup>
                                            <optgroup label="Tòa A2 (Nữ)">
                                                <option value="4">Phòng 101 - Tòa A2</option>
                                                <option value="5">Phòng 102 - Tòa A2</option>
                                                <option value="6">Phòng 103 - Tòa A2</option>
                                            </optgroup>
                                        </select>
                                        <div class="invalid-feedback">Vui lòng chọn phòng của bạn.</div>
                                    </div>

                                    <div class="row mb-3">
                                        <div class="col-sm-6">
                                            <label class="form-label fw-bold small text-muted">Mật khẩu</label>
                                            <input type="password" class="form-control" name="password" id="password" required>
                                        </div>
                                        <div class="col-sm-6">
                                            <label class="form-label fw-bold small text-muted">Nhập lại mật khẩu</label>
                                            <input type="password" class="form-control" name="confirmPassword" required>
                                        </div>
                                    </div>

                                    <button type="submit" class="btn btn-primary w-100 fw-bold py-2 mt-2 shadow-sm">
                                        Đăng ký tài khoản
                                    </button>
                                </form>
                                <hr class="mt-4 mb-3">
                                <div class="text-center">
                                    <a class="small text-decoration-none" href="${pageContext.request.contextPath}/login.jsp">Đã có tài khoản? Đăng nhập ngay!</a>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
    // Bắt lỗi Validation của form
    (function () {
        'use strict'
        var forms = document.querySelectorAll('.needs-validation')
        Array.prototype.slice.call(forms).forEach(function (form) {
            form.addEventListener('submit', function (event) {
                if (!form.checkValidity()) {
                    event.preventDefault()
                    event.stopPropagation()
                }
                form.classList.add('was-validated')
            }, false)
        })
    })()
</script>
</body>
</html>