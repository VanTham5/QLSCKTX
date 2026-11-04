package dao;

import model.SuCo;
import java.util.List;

public interface ISuCoDAO {
    // 1. Nhóm hàm Đọc (Read)
    int countIssueByStatus(int tkId, String status);
    List<SuCo> getTop5RecentIssues(int tkId);
    List<SuCo> getAllSuCoForStaff();
    int countTotalStudents();

    // 2. Nhóm hàm Thêm (Create)
    boolean insertSuCo(SuCo suCo);

    // 3. Nhóm hàm Xóa (Delete)
    boolean deleteSuCo(int suCoId);

    // 4. Nhóm hàm Sửa (Update) - Khai báo hàm update trạng thái bạn đang dùng
    // boolean updateTrangThai(int suCoId, String trangThaiMoi);
}