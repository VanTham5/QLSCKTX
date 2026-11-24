(() => {
    const formSelector = 'form[data-validation]';
    const isTextValid = (text, min, max) =>
        text.trim().length >= min && text.trim().length <= max && !/[<>]/.test(text);

    function validateField(field, valid, message) {
        field.setCustomValidity(valid ? '' : message);
    }

    function validate(form) {
        const fields = form.elements;
        const kind = form.dataset.validation;
        if (kind === 'account' || kind === 'password') {
            const password = kind === 'account' ? fields.matKhau : fields.newPass;
            validateField(password, password.value.trim() && password.value.length >= 6
                && new TextEncoder().encode(password.value).length <= 72,
            'Mật khẩu phải có ít nhất 6 ký tự và tối đa 72 byte.');
        }
        if (kind === 'password') {
            validateField(fields.confirmPass, fields.newPass.value === fields.confirmPass.value,
                'Mật khẩu xác nhận chưa khớp.');
        } else if (kind === 'profile') {
            validateField(fields.fullName, isTextValid(fields.fullName.value, 1, 100), 'Họ tên phải từ 1 đến 100 ký tự hợp lệ.');
            if (fields.maSV) {
                validateField(fields.maSV, isTextValid(fields.maSV.value, 1, 20), 'Mã sinh viên phải từ 1 đến 20 ký tự hợp lệ.');
                validateField(fields.khoa, isTextValid(fields.khoa.value, 1, 100), 'Chọn khoa hợp lệ.');
                validateField(fields.lop, isTextValid(fields.lop.value, 1, 50), 'Lớp phải từ 1 đến 50 ký tự hợp lệ.');
            }
            const phone = fields.sdt.value.trim();
            validateField(fields.sdt, (!phone && !fields.sdt.required) || /^0[0-9]{9}$/.test(phone),
                'Số điện thoại phải có đúng 10 chữ số và bắt đầu bằng số 0.');
            const email = fields.email.value.trim();
            validateField(fields.email, !email || (email.length <= 100 && /^[^\s@<>]+@[^\s@<>]+\.[^\s@<>]+$/.test(email)),
                'Nhập địa chỉ email hợp lệ.');
        } else if (kind === 'account') {
            validateField(fields.hoTen, isTextValid(fields.hoTen.value, 1, 100), 'Nhập họ tên hợp lệ.');
            validateField(fields.tenDangNhap, /^[A-Za-z0-9_.-]{3,50}$/.test(fields.tenDangNhap.value.trim()),
                'Tên đăng nhập từ 3 đến 50 ký tự, chỉ gồm chữ cái, số, dấu chấm, gạch ngang hoặc gạch dưới.');
            validateField(fields.toId, fields.vaiTro.value !== 'NHAN_VIEN' || /^[1-9][0-9]*$/.test(fields.toId.value),
                'Chọn tổ phụ trách cho nhân viên.');
        } else if (kind === 'report') {
            validateField(fields.tieuDe, isTextValid(fields.tieuDe.value, 10, 100), 'Tiêu đề phải từ 10 đến 100 ký tự hợp lệ.');
            validateField(fields.moTa, isTextValid(fields.moTa.value, 20, 5000), 'Mô tả phải từ 20 đến 5.000 ký tự hợp lệ.');
            validateField(fields.loaiSuCoId, /^[1-9][0-9]*$/.test(fields.loaiSuCoId.value), 'Chọn loại sự cố.');
            validateField(fields.mucDo, ['THẤP', 'TRUNG BÌNH', 'KHẨN CẤP'].includes(fields.mucDo.value), 'Chọn mức độ sự cố.');
        }
    }

    function clearValidation(form) {
        for (const field of form.elements) {
            if (typeof field.setCustomValidity === 'function') field.setCustomValidity('');
        }
    }

    document.addEventListener('input', event => {
        const form = event.target.closest(formSelector);
        if (form) clearValidation(form);
    });
    document.addEventListener('change', event => {
        const form = event.target.closest(formSelector);
        if (form) clearValidation(form);
    });
    document.addEventListener('hidden.bs.modal', event => {
        for (const form of event.target.querySelectorAll(formSelector)) clearValidation(form);
    });

    const checking = new WeakSet();
    document.addEventListener('submit', async event => {
        const form = event.target;
        if (!form.matches(formSelector)) return;

        validate(form);
        if (!form.reportValidity()) {
            event.preventDefault();
            return;
        }
        if (form.dataset.validation !== 'account') return;

        event.preventDefault();
        if (checking.has(form)) return;
        checking.add(form);
        const input = form.elements.tenDangNhap;
        const username = input.value.trim();
        const url = new URL(form.getAttribute('action'), location.href);
        url.searchParams.set('action', 'checkUsername');
        url.searchParams.set('username', username);
        try {
            const response = await fetch(url, { cache: 'no-store' });
            if (response.ok && !response.redirected && await response.json() === true
                    && input.value.trim() === username) {
                input.setCustomValidity('Tên đăng nhập đã tồn tại trong hệ thống.');
                input.reportValidity();
                return;
            }
        } catch {
            // The server revalidates uniqueness before creating the account.
        } finally {
            checking.delete(form);
        }
        if (input.value.trim() !== username) return;
        validate(form);
        if (form.reportValidity()) HTMLFormElement.prototype.submit.call(form);
    }, true);
})();
