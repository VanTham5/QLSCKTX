<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="notice" uri="jakarta.tags.core" %>
<div data-notice-batch data-before="${nextNoticeBefore}">
    <notice:forEach var="noticeItem" items="${listTB}">
        <article class="card mb-3 border-0 shadow-sm">
            <div class="card-body">
                <h6 class="fw-bold text-primary mb-1" tabindex="-1"><notice:out value="${noticeItem.tieuDe}"/></h6>
                <div class="text-muted small mb-2"><i class="fa-regular fa-clock me-1" aria-hidden="true"></i> <notice:out value="${noticeItem.ngayTao}"/></div>
                <p class="mb-0 text-dark" style="font-size: 0.95rem;"><notice:out value="${noticeItem.noiDung}"/></p>
            </div>
        </article>
    </notice:forEach>
</div>
