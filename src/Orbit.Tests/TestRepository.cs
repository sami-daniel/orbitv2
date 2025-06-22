using Microsoft.EntityFrameworkCore;
using Orbit.Infrastructure.Repository;
using Bogus;

namespace Orbit.Tests;

public class RepositoryTests
{
    private readonly Faker<TestEntity> _entityFaker;
    private readonly DbContextOptions<TestDbContext> _dbOptions;

    public RepositoryTests()
    {
        _entityFaker = new Faker<TestEntity>()
            .RuleFor(e => e.Id, f => f.Random.Int(1))
            .RuleFor(e => e.Name, f => f.Lorem.Word());

        _dbOptions = new DbContextOptionsBuilder<TestDbContext>()
            .UseInMemoryDatabase(databaseName: Guid.NewGuid().ToString())
            .Options;
    }

    #region GetAsync Tests
    [Fact]
    public async Task GetAsync_ExistingId_ReturnsEntity()
    {
        // Arrange
        using var context = new TestDbContext(_dbOptions);
        var entity = _entityFaker.Generate();
        context.TestEntities.Add(entity);
        await context.SaveChangesAsync();

        var repo = new TestRepository(context);

        // Act
        var result = await repo.GetAsync(entity.Id);

        // Assert
        Assert.NotNull(result);
        Assert.Equal(entity.Id, result.Id);
    }

    [Fact]
    public async Task GetAsync_NonExistingId_ReturnsNull()
    {
        // Arrange
        using var context = new TestDbContext(_dbOptions);
        var repo = new TestRepository(context);

        // Act
        var result = await repo.GetAsync(999);

        // Assert
        Assert.Null(result);
    }

    #endregion

    #region GetAllAsync Tests
    [Fact]
    public async Task GetAllAsync_WithEntities_ReturnsAll()
    {
        // Arrange
        using var context = new TestDbContext(_dbOptions);
        var entities = _entityFaker.Generate(3);
        context.TestEntities.AddRange(entities);
        await context.SaveChangesAsync();

        var repo = new TestRepository(context);

        // Act
        var results = await repo.GetAllAsync();

        // Assert
        Assert.Equal(3, results.Count());
    }

    [Fact]
    public async Task GetAllAsync_EmptyDb_ReturnsEmptyList()
    {
        // Arrange
        using var context = new TestDbContext(_dbOptions);
        var repo = new TestRepository(context);

        // Act
        var results = await repo.GetAllAsync();

        // Assert
        Assert.Empty(results);
    }
    #endregion

    #region AddAsync Tests
    [Fact]
    public async Task AddAsync_ValidEntity_AddsToContext()
    {
        // Arrange
        using var context = new TestDbContext(_dbOptions);
        var entity = _entityFaker.Generate();
        var repo = new TestRepository(context);

        // Act
        await repo.AddAsync(entity);
        await context.SaveChangesAsync();

        // Assert
        Assert.Single(context.TestEntities);
        Assert.Equal(entity.Id, context.TestEntities.First().Id);
    }

    [Fact]
    public async Task AddAsync_NullEntity_Throws()
    {
        // Arrange
        using var context = new TestDbContext(_dbOptions);
        var repo = new TestRepository(context);

        // Act & Assert
        var ex = await Assert.ThrowsAsync<ArgumentNullException>(() => repo.AddAsync(null!));
    }
    #endregion

    #region UpdateAsync Tests
    [Fact]
    public async Task UpdateAsync_ValidEntity_MarksAsModified()
    {
        // Arrange
        using var context = new TestDbContext(_dbOptions);
        var entity = _entityFaker.Generate();
        context.TestEntities.Add(entity);
        await context.SaveChangesAsync();

        var repo = new TestRepository(context);
        entity.Name = "Updated";

        // Act
        await repo.UpdateAsync(entity);
        await context.SaveChangesAsync();

        // Assert
        var updatedEntity = context.TestEntities.Find(entity.Id);
    }

    [Fact]
    public async Task UpdateAsync_NullEntity_Throws()
    {
        // Arrange
        using var context = new TestDbContext(_dbOptions);
        var repo = new TestRepository(context);

        // Act & Assert
        var ex = await Assert.ThrowsAsync<ArgumentNullException>(() => repo.UpdateAsync(null!));
    }
    #endregion

    #region DeleteAsync Tests
    [Fact]
    public async Task DeleteAsync_ValidEntity_RemovesFromContext()
    {
        // Arrange
        using var context = new TestDbContext(_dbOptions);
        var entity = _entityFaker.Generate();
        context.TestEntities.Add(entity);
        await context.SaveChangesAsync();

        var repo = new TestRepository(context);

        // Act
        await repo.DeleteAsync(entity);
        await context.SaveChangesAsync();

        // Assert
        Assert.Empty(context.TestEntities);
    }

    [Fact]
    public async Task DeleteAsync_NullEntity_Throws()
    {
        // Arrange
        using var context = new TestDbContext(_dbOptions);
        var repo = new TestRepository(context);

        // Act & Assert
        var ex = await Assert.ThrowsAsync<ArgumentNullException>(() => repo.DeleteAsync(null!));
    }
    #endregion

    // Test Entity and DbContext
    private class TestEntity
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;
    }

    private class TestDbContext : DbContext
    {
        public TestDbContext(DbContextOptions options) : base(options) { }
        public DbSet<TestEntity> TestEntities { get; set; } = null!;
    }

    // Concrete Repository for testing
    private class TestRepository : Repository<TestEntity>
    {
        public TestRepository(DbContext context) : base(context) { }
    }
}
