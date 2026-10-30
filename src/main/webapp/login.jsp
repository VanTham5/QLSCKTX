<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Đăng nhập - KTX Support</title>
    <!-- Tích hợp Bootstrap 5 -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light d-flex align-items-center justify-content-center" style="height: 100vh;">

<div class="card shadow p-4" style="width: 400px; border-radius: 15px;">
    <h3 class="text-center text-primary mb-4">KTX Support</h3>

    <!-- Đoạn JSTL/EL hiển thị lỗi từ Servlet gửi về -->
    <%
        // Dùng mã Java trực tiếp thay cho JSTL
        String errorMsg = (String) request.getAttribute("error");
        if (errorMsg != null && !errorMsg.isEmpty()) {
    %>
    <div class="alert alert-danger text-center" role="alert">
        <%= errorMsg %>
    </div>
    <%
        }
    %>

    <form action="login" method="post">
        <div class="mb-3">
            <label for="username" class="form-label">Tên đăng nhập</label>
            <input type="text" class="form-control" id="username" name="username" required placeholder="Nhập mã sinh viên / tên đăng nhập">
        </div>
        <div class="mb-3">
            <label for="password" class="form-label">Mật khẩu</label>
            <input type="password" class="form-control" id="password" name="password" required placeholder="Nhập mật khẩu">
        </div>
        <button type="submit" class="btn btn-primary w-100 fw-bold">ĐĂNG NHẬP</button>
    </form>
</div>

</body>
</html>