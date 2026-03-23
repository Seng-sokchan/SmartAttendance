using SmartAttendanceAPI.DTOs.Admin;

namespace SmartAttendanceAPI.Services;

public interface IAdminService
{
    Task<CreateUserResponseDto> CreateUserAsync(CreateUserRequestDto request, CancellationToken cancellationToken = default);
    Task<IReadOnlyList<UserListItemDto>> GetAllUsersAsync(CancellationToken cancellationToken = default);
}
