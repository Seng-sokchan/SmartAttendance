using SmartAttendanceAPI.DTOs.Admin;
using SmartAttendanceAPI.Models;

namespace SmartAttendanceAPI.Repositories;

public interface IUserRepository
{
    Task<UserAuthRecord?> GetByUsernameAsync(string username, string passwordPlain, CancellationToken cancellationToken = default);
    Task<int> CreateUserAsync(string username, string passwordHash, string role, CancellationToken cancellationToken = default);
    Task<IReadOnlyList<UserListItemDto>> GetAllUsersAsync(CancellationToken cancellationToken = default);
}
