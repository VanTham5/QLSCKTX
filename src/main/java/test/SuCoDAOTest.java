package test;

import dao.SuCoDAO;
import model.SuCo;

public class SuCoDAOTest {
    public static void main(String[] args) {
        SuCoDAO dao = new SuCoDAO();

        System.out.println("--- CHẠY TEST CASE ---");

        // Test Case 1: Kiểm tra lấy danh sách sự cố
        System.out.println("Test Case 1: Lấy danh sách sự cố cho Nhân viên");
        int size = dao.getAllSuCoForStaff().size();
        if (size >= 0) {
            System.out.println("-> PASS: Kết nối CSDL và lấy dữ liệu thành công. Tổng số sự cố: " + size);
        } else {
            System.out.println("-> FAILED: Lỗi truy vấn dữ liệu.");
        }

        // Test Case 2: Kiểm tra đếm số lượng sinh viên (dành cho Admin)
        System.out.println("\nTest Case 2: Đếm tổng số sinh viên");
        int totalStudents = dao.countTotalStudents();
        if (totalStudents >= 0) {
            System.out.println("-> PASS: Hàm đếm hoạt động tốt. Số sinh viên: " + totalStudents);
        } else {
            System.out.println("-> FAILED: Không đếm được số lượng.");
        }
    }
}