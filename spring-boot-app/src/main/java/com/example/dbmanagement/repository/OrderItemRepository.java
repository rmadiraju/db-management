package com.example.dbmanagement.repository;

import com.example.dbmanagement.entity.OrderItem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.util.List;

@Repository
public interface OrderItemRepository extends JpaRepository<OrderItem, Long> {
    
    /**
     * Find order items by order ID
     */
    List<OrderItem> findByOrderId(Long orderId);
    
    /**
     * Find order items by product ID
     */
    List<OrderItem> findByProductId(Long productId);
    
    /**
     * Find order items by order ID and product ID
     */
    List<OrderItem> findByOrderIdAndProductId(Long orderId, Long productId);
    
    /**
     * Find order items with quantity greater than specified amount
     */
    List<OrderItem> findByQuantityGreaterThan(Integer quantity);
    
    /**
     * Find order items with unit price greater than specified amount
     */
    List<OrderItem> findByUnitPriceGreaterThan(BigDecimal unitPrice);
    
    /**
     * Find order items with total price greater than specified amount
     */
    List<OrderItem> findByTotalPriceGreaterThan(BigDecimal totalPrice);
    
    /**
     * Calculate total quantity for a specific order
     */
    @Query("SELECT SUM(oi.quantity) FROM OrderItem oi WHERE oi.orderId = :orderId")
    Integer calculateTotalQuantityByOrder(@Param("orderId") Long orderId);
    
    /**
     * Calculate total amount for a specific order
     */
    @Query("SELECT SUM(oi.totalPrice) FROM OrderItem oi WHERE oi.orderId = :orderId")
    BigDecimal calculateTotalAmountByOrder(@Param("orderId") Long orderId);
    
    /**
     * Find most popular products (by total quantity sold)
     */
    @Query("SELECT oi.productId, SUM(oi.quantity) as totalQuantity FROM OrderItem oi GROUP BY oi.productId ORDER BY totalQuantity DESC")
    List<Object[]> findMostPopularProducts();
    
    /**
     * Find products with highest revenue
     */
    @Query("SELECT oi.productId, SUM(oi.totalPrice) as totalRevenue FROM OrderItem oi GROUP BY oi.productId ORDER BY totalRevenue DESC")
    List<Object[]> findProductsWithHighestRevenue();
    
    /**
     * Find order items by order ID ordered by creation date
     */
    @Query("SELECT oi FROM OrderItem oi WHERE oi.orderId = :orderId ORDER BY oi.createdAt ASC")
    List<OrderItem> findByOrderIdOrderByCreatedAtAsc(@Param("orderId") Long orderId);
    
    /**
     * Calculate average order value
     */
    @Query("SELECT AVG(oi.totalPrice) FROM OrderItem oi")
    BigDecimal calculateAverageOrderItemValue();
    
    /**
     * Find order items with quantity between specified range
     */
    @Query("SELECT oi FROM OrderItem oi WHERE oi.quantity BETWEEN :minQuantity AND :maxQuantity")
    List<OrderItem> findByQuantityBetween(@Param("minQuantity") Integer minQuantity, @Param("maxQuantity") Integer maxQuantity);
    
    /**
     * Count order items by product ID
     */
    @Query("SELECT COUNT(oi) FROM OrderItem oi WHERE oi.productId = :productId")
    Long countByProductId(@Param("productId") Long productId);
    
    /**
     * Find order items created after a specific date
     */
    @Query("SELECT oi FROM OrderItem oi WHERE oi.createdAt >= :date ORDER BY oi.createdAt DESC")
    List<OrderItem> findOrderItemsCreatedAfter(@Param("date") java.time.LocalDateTime date);
}
