using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SmartAttendanceAPI.Constants;
using SmartAttendanceAPI.DTOs.Admin;
using SmartAttendanceAPI.Services;

namespace SmartAttendanceAPI.Controllers;

[ApiController]
[Route("api/admin")]
[Authorize(Roles = AppRoles.Admin)]
public sealed class AdminController : ControllerBase
{
    private readonly IAdminService _admin;

    public AdminController(IAdminService admin)
    {
        _admin = admin;
    }

    [HttpPost("create-user")]
    [ProducesResponseType(typeof(CreateUserResponseDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<ActionResult<CreateUserResponseDto>> CreateUser([FromBody] CreateUserRequestDto request, CancellationToken cancellationToken)
    {
        var result = await _admin.CreateUserAsync(request, cancellationToken);
        return Ok(result);
    }

    [HttpGet("users")]
    [ProducesResponseType(typeof(IReadOnlyList<UserListItemDto>), StatusCodes.Status200OK)]
    public async Task<ActionResult<IReadOnlyList<UserListItemDto>>> GetUsers(CancellationToken cancellationToken)
    {
        var users = await _admin.GetAllUsersAsync(cancellationToken);
        return Ok(users);
    }
}
