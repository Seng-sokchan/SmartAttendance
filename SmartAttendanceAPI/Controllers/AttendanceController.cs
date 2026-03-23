using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SmartAttendanceAPI.DTOs.Attendance;
using SmartAttendanceAPI.Helpers;
using SmartAttendanceAPI.Services;

namespace SmartAttendanceAPI.Controllers;

[ApiController]
[Route("api/attendance")]
[Authorize]
public sealed class AttendanceController : ControllerBase
{
    private readonly IAttendanceService _attendance;

    public AttendanceController(IAttendanceService attendance)
    {
        _attendance = attendance;
    }

    [HttpPost("check-in")]
    [ProducesResponseType(typeof(CheckInResponseDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<ActionResult<CheckInResponseDto>> CheckIn([FromBody] LocationRequestDto request, CancellationToken cancellationToken)
    {
        var userId = User.GetUserId();
        var result = await _attendance.CheckInAsync(userId, request, cancellationToken);
        return Ok(result);
    }

    [HttpPost("check-out")]
    [ProducesResponseType(typeof(CheckOutResponseDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<ActionResult<CheckOutResponseDto>> CheckOut([FromBody] LocationRequestDto request, CancellationToken cancellationToken)
    {
        var userId = User.GetUserId();
        var result = await _attendance.CheckOutAsync(userId, request, cancellationToken);
        return Ok(result);
    }

    [HttpGet("my-records")]
    [ProducesResponseType(typeof(IReadOnlyList<AttendanceRecordDto>), StatusCodes.Status200OK)]
    public async Task<ActionResult<IReadOnlyList<AttendanceRecordDto>>> MyRecords(CancellationToken cancellationToken)
    {
        var userId = User.GetUserId();
        var records = await _attendance.GetMyRecordsAsync(userId, cancellationToken);
        return Ok(records);
    }
}
