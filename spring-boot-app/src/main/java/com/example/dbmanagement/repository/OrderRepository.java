package com.example.dbmanagement.repository;

import com.example.dbmanagement.entity.Order;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface OrderRepository extends JpaRepository<Order, Long> {
    
    /**
     * Find order by order number
     */
    Optional<Order> findByOrderNumber(String orderNumber);
    
    /**
     * Find orders by user ID
     */
    List<Order> findByUserId(Long userId);
    
    /**
     * Find orders by status
     */
    List<Order> findByStatus(Order.OrderStatus status);
    
    /**
     * Find orders by user ID and status
     */
    List<Order> findByUserIdAndStatus(Long userId, Order.OrderStatus status);
    
    /**
     * Find orders created after a specific date
     */
    List<Order> findByCreatedAtAfter(LocalDateTime date);
    
    /**
     * Find orders created between two dates
     */
    List<Order> findByCreatedAtBetween(LocalDateTime startDate, LocalDateTime endDate);
    
    /**
     * Find orders by total amount range
     */
    List<Order> findByTotalAmountBetween(BigDecimal minAmount, BigDecimal maxAmount);
    
    /**
     * Check if order number exists
     */
    boolean existsByOrderNumber(String orderNumber);
    
    /**
     * Find orders by user ID ordered by creation date (newest first)
     */
    @Query("SELECT o FROM Order o WHERE o.userId = :userId ORDER BY o.createdAt DESC")
    List<Order> findByUserIdOrderByCreatedAtDesc(@Param("userId") Long userId);
    
    /**
     * Find recent orders (last N days)
     */
    @Query("SELECT o FROM Order o WHERE o.createdAt >= :since ORDER BY o.createdAt DESC")
    List<Order> findRecentOrders(@Param("since") LocalDateTime since);
    
    /**
     * Calculate total sales amount
     */
    @Query("SELECT SUM(o.totalAmount) FROM Order o WHERE o.status IN ('CONFIRMED', 'SHIPPED', 'DELIVERED')")
    BigDecimal calculateTotalSales();
    
    /**
     * Calculate total sales amount for a specific user
     */
    @Query("SELECT SUM(o.totalAmount) FROM Order o WHERE o.userId = :userId AND o.status IN ('CONFIRMED', 'SHIPPED', 'DELIVERED')")
    BigDecimal calculateTotalSalesByUser(@Param("userId") Long userId);
    
    /**
     * Count orders by status
     */
    @Query("SELECT o.status, COUNT(o) FROM Order o GROUP BY o.status")
    List<Object[]> countOrdersByStatus();
    
    /**
     * Find orders with total amount greater than specified value
     */
    @Query("SELECT o FROM Order o WHERE o.totalAmount > :amount ORDER BY o.totalAmount DESC")
    List<Order> findOrdersWithAmountGreaterThan(@Param("amount") BigDecimal amount);
    
    /**
     * Find orders by user ID and date range
     */
    @Query("SELECT o FROM Order o WHERE o.userId = :userId AND o.createdAt BETWEEN :startDate AND :endDate ORDER BY o.createdAt DESC")
    List<Order> findByUserIdAndDateRange(@Param("userId") Long userId, 
                                         @Param("startDate") LocalDateTime startDate, 
                                         @Param("endDate") LocalDateTime endDate);
}
