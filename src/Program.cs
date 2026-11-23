using Dapper;
using Microsoft.AspNetCore.SignalR;
using MySqlConnector;

var b = WebApplication.CreateBuilder(args);
b.Services.AddSignalR();
var cs = b.Configuration.GetConnectionString("Db")!;
var editKey = b.Configuration["EditKey"];
var app = b.Build();
app.UseDefaultFiles(); app.UseStaticFiles();
app.MapHub<StockHub>("/hub");

// ทุกคนดูได้
app.MapGet("/api/slots", async () => {
    using var c = new MySqlConnection(cs);
    return await c.QueryAsync<SlotRow>(@"SELECT s.SlotId,s.Warehouse,s.Zone,s.Rack,s.Position,s.Code,s.CapacityBags,
        k.Resin,k.LotNo,k.QtyBags,k.UpdatedAt,k.UpdatedBy
        FROM Slot s LEFT JOIN Stock k ON k.SlotId=s.SlotId ORDER BY s.SortOrder");
});

// เฉพาะคนที่มี X-Edit-Key เท่านั้นที่แก้ได้
app.MapPut("/api/slots/{id:int}/stock", async (int id, StockDto d, HttpRequest r, IHubContext<StockHub> hub) => {
    if (string.IsNullOrEmpty(editKey) || r.Headers["X-Edit-Key"].ToString() != editKey) return Results.Unauthorized();
    using var c = new MySqlConnection(cs);
    await c.OpenAsync();
    using var tx = await c.BeginTransactionAsync();
    var before = await c.QuerySingleOrDefaultAsync<decimal?>("SELECT QtyBags FROM Stock WHERE SlotId=@id", new { id }, tx);
    await c.ExecuteAsync(@"UPDATE Stock SET Resin=@Resin,LotNo=@LotNo,QtyBags=@QtyBags,UpdatedAt=NOW(),UpdatedBy=@UpdatedBy WHERE SlotId=@id",
        new { id, d.Resin, d.LotNo, d.QtyBags, d.UpdatedBy }, tx);
    await c.ExecuteAsync(@"INSERT INTO StockLog(SlotId,Resin,LotNo,QtyBefore,QtyAfter,ChangedBy) VALUES(@id,@Resin,@LotNo,@before,@QtyBags,@UpdatedBy)",
        new { id, d.Resin, d.LotNo, before, d.QtyBags, d.UpdatedBy }, tx);
    await tx.CommitAsync();
    await hub.Clients.All.SendAsync("changed", id);   // ทุกหน้าที่เปิดอยู่รีเฟรชเอง
    return Results.Ok();
});
app.Run();

record StockDto(string? Resin, string? LotNo, decimal? QtyBags, string? UpdatedBy);
class SlotRow {
    public int SlotId { get; set; } public string Warehouse { get; set; } = ""; public string Zone { get; set; } = "";
    public string Rack { get; set; } = ""; public int Position { get; set; } public string Code { get; set; } = "";
    public int CapacityBags { get; set; } public string? Resin { get; set; } public string? LotNo { get; set; }
    public decimal? QtyBags { get; set; } public DateTime? UpdatedAt { get; set; } public string? UpdatedBy { get; set; }
}
class StockHub : Hub { }
